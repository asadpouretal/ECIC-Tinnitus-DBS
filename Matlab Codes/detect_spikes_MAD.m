function [spike_times_MAD, spike_train] = detect_spikes_MAD(data, params, sampling_rate)
    % Calculate the threshold using MAD method for positive and negative spikes
    multiplier = params.MAD_multiplier;
    threshold = median(abs(data)) + multiplier * mad(abs(data), 1);
    upper_limit = 2 * threshold; % Define upper limit for spikes
    
    % Find positive and negative spike indices
    spike_indices_positive = find(data > threshold); % & data <= upper_limit);
    spike_indices_negative = []; % Uncomment if needed: find(data < -threshold & data >= -upper_limit);
    
    % Ensure both are row vectors before concatenating
    spike_indices_positive = spike_indices_positive(:)';
    spike_indices_negative = spike_indices_negative(:)';
    
    % Combine and sort spike indices
    spike_indices = sort([spike_indices_positive, spike_indices_negative]);
    
    
    % Filter out consecutive spikes within 2.6 ms, keeping only the larger one
    min_time_diff = params.min_ISI / 1000; % Convert ms to seconds
    min_samples_diff = round(min_time_diff * sampling_rate);
    
    
    n = length(spike_indices);
    to_remove = false(n, 1);

    i = 1;
    while i < n
        j = i + 1;
        while j <= n && (spike_indices(j) - spike_indices(i)) <= min_samples_diff
            if abs(data(spike_indices(j))) <= abs(data(spike_indices(i)))
                to_remove(j) = true;
                j = j + 1;
            else
                to_remove(i) = true;
                i = j;
                j = j + 1;
            end
        end
        i = i + 1;
    end

    % Remove the identified indices
    spike_indices(to_remove) = [];

    % Construct spike times from the remaining indices
    spike_times_MAD = spike_indices;

    % Construct the spike train
    spike_train = zeros(size(data));
    spike_train(spike_indices) = 1;
end
