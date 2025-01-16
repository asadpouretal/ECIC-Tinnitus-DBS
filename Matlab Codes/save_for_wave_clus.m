function output_full_filename = save_for_wave_clus(sampling_rate, spike_waveforms, spike_times, output_folder, filename)
    % Ensure the output folder exists
    [~, outputfile, ~] = fileparts(filename);
    output_folder = fullfile(output_folder, outputfile);
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    % Convert spike times to milliseconds
    spike_times_ms = (spike_times / sampling_rate) * 1000;
    
    % Create a structure for Wave_Clus
    spikes = spike_waveforms;
    index = spike_times_ms;
    % Construct the full filename with path
    output_full_filename = fullfile(output_folder, [outputfile '_spikes.mat']);
    
    % Save the data in the format expected by Wave_Clus
    save(output_full_filename, 'spikes', 'index');
end