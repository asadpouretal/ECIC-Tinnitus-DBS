function spike_waveforms = extract_spike_waveforms(data, spike_times, sampling_rate, params)
    % Define the window lengths
    pre_peak_time = params.pre_peak_time; % default: 0.6 ms before the peak
    post_peak_time = params.post_peak_time; % default: 0.4 ms after the peak

    % Convert time to number of samples
    pre_peak_samples = round(pre_peak_time * sampling_rate);
    post_peak_samples = round(post_peak_time * sampling_rate);
    
    % Initialize matrix to hold spike waveforms
    spike_length = pre_peak_samples + post_peak_samples + 1;
    spike_waveforms = zeros(length(spike_times), spike_length);
    
    % Extract waveforms
    for i = 1:length(spike_times)
        if spike_times(i) > pre_peak_samples && spike_times(i) + post_peak_samples <= length(data)
            spike_waveforms(i, :) = data(spike_times(i) - pre_peak_samples : spike_times(i) + post_peak_samples);
        end
    end
end
