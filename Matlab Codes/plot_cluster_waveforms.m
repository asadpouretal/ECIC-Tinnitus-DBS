function [cluster_spikes, cluster_spike_times, cluster_spike_trains, cluster_firing_rates] = plot_cluster_waveforms(spike_waveforms, spike_times, Idx_sort, filtered_data, sampling_rate, params)
    % Get unique cluster indices
    unique_clusters = unique(Idx_sort);
    FR_new_sampling_rate = params.down_sampled_FR_frequency;
    % Colorblind-friendly color palette
    colors = [
        0, 114, 178;    % Blue
        213, 94, 0;     % Vermillion
        0, 158, 115;    % Bluish Green
        240, 228, 66;   % Yellow
        86, 180, 233;   % Sky Blue
        204, 121, 167;  % Reddish Purple
        0, 0, 0         % Black
    ] / 255;  % Normalize to [0, 1] range
    
    % Initialize cell arrays to store outputs
    cluster_spikes = cell(length(unique_clusters), 1);
    cluster_spike_times = cell(length(unique_clusters), 1);
    cluster_spike_trains = cell(length(unique_clusters), 1);
    cluster_firing_rates = cell(length(unique_clusters), 1);
    
    % Initialize figure
    figure;
    hold on;
    
    % Loop through each cluster
    for i = 1:length(unique_clusters)
        cluster_idx = unique_clusters(i);
        
        % Extract waveforms for the current cluster
        cluster_waveforms = spike_waveforms(Idx_sort == cluster_idx, :);
        cluster_spike_times{i} = spike_times(Idx_sort == cluster_idx);
        cluster_spike_trains{i} = zeros(size(filtered_data));
        cluster_spike_trains{i}(cluster_spike_times{i}) = 1;
        
        % Store the spikes of the current cluster
        cluster_spikes{i} = cluster_waveforms;
        
        % Compute mean waveform
        mean_waveform = mean(cluster_waveforms, 1);
        
        % Compute 95% confidence interval
        sem = std(cluster_waveforms, 0, 1) / sqrt(size(cluster_waveforms, 1)); % Standard error of the mean
        ci95 = 1.96 * sem; % 95% confidence interval
        
        % Time vector for plotting
        time_vector = (0:size(cluster_waveforms, 2) - 1) / sampling_rate * 1000; % Convert to ms
        
        % Plot mean waveform with 95% confidence interval
        color_idx = mod(i-1, size(colors, 1)) + 1; % Cycle through colors
        fill([time_vector, fliplr(time_vector)], ...
             [mean_waveform - ci95, fliplr(mean_waveform + ci95)], ...
             colors(color_idx, :), 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        plot(time_vector, mean_waveform, 'Color', colors(color_idx, :), 'LineWidth', 2);
        
        % Compute firing rate
        window_duration = params.window_duration; % Example window duration of 100 ms
        [firing_rate_signal, avg_firing_rate(i)] = compute_firing_rate(cluster_spike_trains{i}, sampling_rate, window_duration, FR_new_sampling_rate);

        % Store firing rate information
        cluster_firing_rates{i} = struct('signal', firing_rate_signal, 'average', avg_firing_rate(i));
    end
    
    % Labels and title
    xlabel('Time (ms)');
    ylabel('Amplitude');
    title('Average Waveforms and 95% CI for Each Cluster');
    legend(arrayfun(@(x) sprintf('FR = %.2f Hz', x), avg_firing_rate, 'UniformOutput', false));
    hold off;
    
    % Plot firing rates for each cluster
    figure;
    hold on;
    for i = 1:length(unique_clusters)
        color_idx = mod(i-1, size(colors, 1)) + 1; % Cycle through colors
        firing_rate_signal = cluster_firing_rates{i}.signal;
        time_vector = (1:length(firing_rate_signal)) / FR_new_sampling_rate; % Convert to seconds
        plot(time_vector, firing_rate_signal, 'Color', colors(color_idx, :), 'LineWidth', 1.5);
    end
    xlabel('Time (s)');
    ylabel('Firing Rate (Hz)');
    title('Firing Rates for Each Cluster');
    legend(arrayfun(@(x) sprintf('Cluster %d', x), unique_clusters, 'UniformOutput', false));
    hold off;
end
