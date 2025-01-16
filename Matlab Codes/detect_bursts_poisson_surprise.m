function [bursts, avg_burst_firing_rate, burst_durations, intraburst_frequencies, burst_firing_rate] = detect_bursts_poisson_surprise(spike_train, sampling_rate)
    % Find the indices of the spikes
    spike_indices = find(spike_train);

    % Calculate the Inter-Spike Intervals (ISIs) in seconds
    ISIs = diff(spike_indices) / sampling_rate;

    % Calculate the overall firing rate (spikes per second)
    total_spikes = length(spike_indices);
    total_time = length(spike_train) / sampling_rate;
    firing_rate = total_spikes / total_time;

    % Calculate the Poisson surprise values
    prob_values = poisspdf(round(ISIs * firing_rate), 1);
    prob_values(prob_values == 0) = realmin;  % Avoid log(0)
    surprise_values = -log(prob_values);

    % Identify bursts based on a surprise threshold
    surprise_threshold = 5; % Commonly used threshold value
    burst_indices = find(surprise_values > surprise_threshold);

    % Group consecutive spikes into bursts
    bursts = {};
    current_burst = [];
    for i = 1:length(burst_indices)
        if i == 1 || burst_indices(i) - burst_indices(i-1) == 1
            current_burst = [current_burst, spike_indices(burst_indices(i))];
        else
            bursts{end + 1} = current_burst;
            current_burst = [spike_indices(burst_indices(i))];
        end
    end
    if ~isempty(current_burst)
        bursts{end + 1} = current_burst;
    end

    % Calculate average burst firing rate per minute
    avg_burst_firing_rate = length(bursts) / (total_time / 60);

    % Calculate burst firing durations and intraburst frequencies
    burst_durations = [];
    intraburst_frequencies = [];
    for i = 1:length(bursts)
        burst_duration = (bursts{i}(end) - bursts{i}(1)) / sampling_rate;
        burst_durations = [burst_durations, burst_duration];
        if length(bursts{i}) > 1
            intraburst_frequency = (length(bursts{i}) - 1) / burst_duration;
            intraburst_frequencies = [intraburst_frequencies, intraburst_frequency];
        else
            intraburst_frequencies = [intraburst_frequencies, NaN];
        end
    end

    % Calculate and visualize burst firing rate
    burst_firing_rate = zeros(size(spike_train));
    for i = 1:length(bursts)
        burst_firing_rate(bursts{i}) = 1;
    end
    burst_firing_rate = burst_firing_rate * avg_burst_firing_rate; % Normalize to average burst firing rate

    % Plot the burst firing rate signal
    time_vector = (1:length(burst_firing_rate)) / sampling_rate;
    figure;
    plot(time_vector, burst_firing_rate, 'LineWidth', 1.5);
    xlabel('Time (s)');
    ylabel('Burst Firing Rate (bursts/min)');
    title(['Average Burst Firing Rate: ', num2str(avg_burst_firing_rate), ' bursts/min']);
    grid on;
end
