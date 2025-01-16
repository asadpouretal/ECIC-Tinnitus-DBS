function downsampled_spike_train = spike_downsample(spike_train, original_rate, new_rate)
    fprintf('Downsampling spike_train...\n');
    % Downsample spike_train from original_rate to new_rate while maintaining all spikes
    factor = original_rate / new_rate;
    num_samples = length(spike_train);
    downsampled_num_samples = round(num_samples / factor);
    
    downsampled_spike_train = zeros(1, downsampled_num_samples);
    for i = 1:downsampled_num_samples
        start_idx = round((i - 1) * factor) + 1;
        end_idx = min(round(i * factor), num_samples);
        downsampled_spike_train(i) = max(spike_train(start_idx:end_idx));
    end
    fprintf('Downsampling complete.\n');
end