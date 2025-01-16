function [firing_rate_signal, avg_firing_rate] = compute_firing_rate(spike_train, sampling_rate, window_duration, new_rate)
    % Given: spike_train, sampling_rate, window_duration
    downsampled_spike_train = spike_downsample(spike_train, sampling_rate, new_rate);
    % Create a Boxcar Kernel
    window_samples = round(window_duration * new_rate);
    boxcar_kernel = ones(1, window_samples);
    boxcar_kernel = boxcar_kernel / (sum(boxcar_kernel) / new_rate^(0.5)); % Adjust for bin width and double filtering

    % Apply Zero-Phase Filtering
    firing_rate_signal = filtfilt(boxcar_kernel, 1, downsampled_spike_train);

    % Calculate the Average Firing Rate
    total_spikes = sum(spike_train);
    total_time = length(spike_train) / sampling_rate; % in seconds
    avg_firing_rate = total_spikes / total_time; % spikes per second

    % % Plot the Firing Rate Signal
    % time_vector = (1:length(downsampled_spike_train)) / new_rate;
    % figure;
    % plot(time_vector, firing_rate_signal, 'LineWidth', 1.5);
    % xlabel('Time (s)');
    % ylabel('Firing Rate (Hz)');
    % title(['Average Firing Rate: ', num2str(avg_firing_rate), ' Hz']);
    % grid on;
end
