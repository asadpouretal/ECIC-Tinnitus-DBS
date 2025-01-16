function [firing_rate_signal, avg_firing_rate] = compute_firing_rate_gaussian(spike_train, sampling_rate, sigma_duration)
    % Given: spike_train, sampling_rate, sigma_duration (standard deviation of Gaussian in seconds)

    % Create a Gaussian Kernel
    sigma_samples = round(sigma_duration * sampling_rate);
    time = (-3*sigma_samples):(3*sigma_samples); % Typically, a Gaussian is truncated at 3 sigma
    gaussian_kernel = exp(-time.^2 / (2*sigma_samples^2));
    gaussian_kernel = (gaussian_kernel / sum(gaussian_kernel)) * sampling_rate^(0.5); % Adjust for bin width

    % Apply Zero-Phase Filtering
    firing_rate_signal = filtfilt(gaussian_kernel, 1, spike_train);

    % Calculate the Average Firing Rate
    total_spikes = sum(spike_train);
    total_time = length(spike_train) / sampling_rate; % in seconds
    avg_firing_rate = total_spikes / total_time; % spikes per second

    % Plot the Firing Rate Signal
    time_vector = (1:length(spike_train)) / sampling_rate;
    figure;
    plot(time_vector, firing_rate_signal, 'LineWidth', 1.5);
    xlabel('Time (s)');
    ylabel('Firing Rate (Hz)');
    title(['Average Firing Rate: ', num2str(avg_firing_rate), ' Hz']);
    grid on;
end
