function results = analyze_spike_data(main_path, file_name, params)
    file_fullpath = fullfile(main_path, file_name);

    [info, data] = ImportStreamData(file_fullpath);
    sampling_rate = extract_sampling_frequency(info);

    tic;
    fprintf('Filtering data...\n');
    filtered_data = bandpass_filter(data, params.low_cutoff, params.high_cutoff, sampling_rate);
    t = toc;
    fprintf('Data filtered in %.2f minutes.\n', t / 60);

    tic;
    fprintf('Calculating MAD...\n');
    [spike_times_MAD, spike_train, MAD_multiplier] = calculate_MAD(filtered_data, params, sampling_rate);
    params.MAD_multiplier = MAD_multiplier;
    t = toc;
    fprintf('MAD calculated in %.2f minutes.\n', t / 60);
    
    tic;
    fprintf('Calculating spike waveforms...\n');
    spike_waveforms = extract_spike_waveforms(filtered_data, spike_times_MAD, sampling_rate, params);
    t = toc;
    fprintf('Spike waveforms calculated in %.2f minutes.\n', t / 60);

    % Sample_data=size(spike_waveforms,1);
    % 
    % Dim_sub=3; %dim of feature subspace
    % numCluster0=4; %initial cluster num
    % flagMerge=1; %1:merge 0: non-merge

    output_full_filename = save_for_wave_clus(sampling_rate, spike_waveforms, spike_times_MAD, main_path, file_name);
    current_file_path = mfilename('fullpath');
    [current_folder, ~, ~] = fileparts(current_file_path);
    [output_folder, ~, ~] = fileparts(output_full_filename);
    [~, output_filename, ~] = fileparts(file_name);
    cd(output_folder)
    par.sr = sampling_rate;
    Do_clustering(output_full_filename, 'par', par);
    load(fullfile(output_folder, ['times_' output_filename '.mat']), 'cluster_class');
    cd(current_folder)
    
    % [Idx_sort,Idx_center]=ldadp_fuc(spike_waveforms,Sample_data,Dim_sub,numCluster0,flagMerge);
    
    [cluster_spikes, cluster_spike_times, cluster_spike_trains, cluster_firing_rates] = plot_cluster_waveforms(spike_waveforms, spike_times_MAD, cluster_class(:,1), filtered_data, sampling_rate, params);


    tic;
    fprintf('Estimating spontaneous firing rate...\n');
    [firing_rate_signal, avg_firing_rate] = compute_firing_rate_for_avg(spike_train, sampling_rate, params.window_duration, params.down_sampled_FR_frequency);
    fprintf('The spontaneous firing rate is %.2f Hz\n', avg_firing_rate);
    [ISIs, avg_ISI] = compute_ISI_distribution(spike_train, sampling_rate);
    fprintf('The spontaneous average ISI is %.2f ms\n', avg_ISI);
    t = toc;
    fprintf('Spontaneous firing rate estimated in %.2f minutes.\n', t / 60);

    % tic;
    % fprintf('Detecting bursts...\n');
    % [bursts, avg_burst_firing_rate, burst_durations, intraburst_frequencies, burst_firing_rate] = detect_bursts_bauer_et_al(spike_train, sampling_rate, ...
    %     'T_max', params.T_max, 'ISI_start_max', params.ISI_start_max, 'ISI_within_max', params.ISI_within_max, 'T_min_between', params.T_min_between, 'T_min', params.T_min, 'N_min', params.N_min);
    % averaged_intraburst_frequencies = mean(intraburst_frequencies);
    % fprintf('Bursts detected.\n');
    % t = toc;
    % fprintf('Bursts detected in %.2f minutes.\n', t / 60);

    % tic;
    % fprintf('Downsampling spike_train to 5000 Hz...\n');
    % downsampled_spike_train = spike_downsample(spike_train, sampling_rate, 5000);
    % downsampled_firing_rate_signal = downsample(firing_rate_signal, sampling_rate / 5000);
    % fprintf('Downsampling complete.\n');
    % t = toc;
    % fprintf('Downsampling completed in %.2f minutes.\n', t / 60);

    % Store all output variables in a structure
    results.params = params;
    results.file_name = file_fullpath;
    results.sampling_rate = sampling_rate;
    results.spike_times_MAD = spike_times_MAD;
    results.spike_waveforms = spike_waveforms;
    results.cluster_class = cluster_class;
    results.cluster_spikes = cluster_spikes;
    results.cluster_spike_times = cluster_spike_times;
    results.cluster_firing_rates = cluster_firing_rates;
    results.avg_firing_rate = avg_firing_rate;
    results.avg_ISI = avg_ISI;
    results.ISIs = ISIs;      
    results.downsampled_firing_rate_signal = firing_rate_signal;
  
    % results.bursts = bursts;
    % results.avg_burst_firing_rate = avg_burst_firing_rate;
    % results.burst_durations = burst_durations;
    % results.intraburst_frequencies = intraburst_frequencies;
    % results.averaged_intraburst_frequencies = averaged_intraburst_frequencies;
    % results.burst_firing_rate = burst_firing_rate;



    tic;
    fprintf('Saving results...\n');
    % Save results in Results folder
    results_folder = fullfile(main_path, 'Results');
    if ~exist(results_folder, 'dir')
        mkdir(results_folder);
    end
    save(fullfile(results_folder, 'results.mat'), 'results', '-v7.3');
    
    % Save figures in Figures folder
    figures_folder = fullfile(main_path, 'Figures');
    if ~exist(figures_folder, 'dir')
        mkdir(figures_folder);
    end

    fig_handles = findobj('Type', 'figure');
    for i = 1:length(fig_handles)
        fig_filename = fullfile(figures_folder, sprintf('figure%d', i));
        savefig(fig_handles(i), [fig_filename, '.fig']);
        saveas(fig_handles(i), [fig_filename, '.svg']);
    end

    % Save CSV file
    % T = table(avg_firing_rate, avg_ISI, avg_burst_firing_rate, averaged_intraburst_frequencies);
    % T.Properties.VariableNames = {'Average Firing Rate (Hz)', 'Average ISI (s)', 'Average Burst Firing Rate (bursts/min)', 'Averaged Intraburst Frequencies (Hz)'};
    % writetable(T, fullfile(results_folder, 'results.csv'));

    t = toc;
    fprintf('Results saved in %.2f minutes.\n', t / 60);
end
