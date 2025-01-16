function [bursts, avg_burst_firing_rate, burst_durations, intraburst_frequencies, burst_rate_signal] = detect_bursts_bauer_et_al(spike_train, sampling_rate, varargin)
    % This function detects spike bursts in neural data using the algorithm
    % described in "Tinnitus and Inferior Colliculus Activity in Chinchillas 
    % Related to Three Distinct Patterns of Cochlear Trauma" by Carol A. Bauer et al.
    % The algorithm considers six parameters:
    % 1) Maximum allowable burst duration (T_max)
    % 2) Maximum interspike interval at burst start (ISI_start_max)
    % 3) Maximum within-burst interspike interval (ISI_within_max)
    % 4) Minimum interval between bursts (T_min_between)
    % 5) Minimum burst duration (T_min)
    % 6) Minimum number of spikes comprising a burst (N_min).
    %
    % If the function is called without specifying these parameters,
    % the default values from the paper will be used:
    % T_max = 310 sec, ISI_start_max = 500 msec, ISI_within_max = 500 msec,
    % T_min_between = 1 sec, T_min = 5 msec, and N_min = 2.
    
    % Set default parameter values
    p = inputParser;
    addParameter(p, 'T_max', 310, @isnumeric);
    addParameter(p, 'ISI_start_max', 0.5, @isnumeric);
    addParameter(p, 'ISI_within_max', 0.5, @isnumeric);
    addParameter(p, 'T_min_between', 1, @isnumeric);
    addParameter(p, 'T_min', 0.005, @isnumeric);
    addParameter(p, 'N_min', 2, @isnumeric);
    
    % Parse input parameters
    parse(p, varargin{:});
    
    % Extract parameter values
    T_max = p.Results.T_max;
    ISI_start_max = p.Results.ISI_start_max;
    ISI_within_max = p.Results.ISI_within_max;
    T_min_between = p.Results.T_min_between;
    T_min = p.Results.T_min;
    N_min = p.Results.N_min;

    % Rest of the function
    % Find the indices of the spikes
    spike_indices = find(spike_train);

    % Calculate the Inter-Spike Intervals (ISIs) in seconds
    ISIs = diff(spike_indices) / sampling_rate;

    % Identify potential bursts based on ISI_within_max
    potential_burst_indices = find(ISIs <= ISI_within_max);

    % Group consecutive spikes into potential bursts
    potential_bursts = {};
    current_burst = [spike_indices(1)];
    for i = 1:length(potential_burst_indices)
        if potential_burst_indices(i) == length(ISIs) || ISIs(potential_burst_indices(i) + 1) > ISI_within_max
            current_burst = [current_burst, spike_indices(potential_burst_indices(i) + 1)];
            potential_bursts{end + 1} = current_burst;
            if potential_burst_indices(i) ~= length(ISIs)
                current_burst = [spike_indices(potential_burst_indices(i) + 2)];
            end
        else
            current_burst = [current_burst, spike_indices(potential_burst_indices(i) + 1)];
        end
    end

    % Apply other criteria to identify valid bursts
    bursts = {};
    last_burst_end = -Inf;  % Initialize last burst end time
    for i = 1:length(potential_bursts)
        n_spikes = length(potential_bursts{i});
        burst_start = potential_bursts{i}(1) / sampling_rate;
        burst_end = potential_bursts{i}(end) / sampling_rate;
        burst_duration = burst_end - burst_start;
    
        % Remove spikes that are too close to the previous burst
        valid_spikes = potential_bursts{i}(potential_bursts{i} / sampling_rate - last_burst_end > T_min_between);
        n_valid_spikes = length(valid_spikes);
    
        % Check if there are any valid spikes
        if n_valid_spikes > 0
            valid_burst_start = valid_spikes(1) / sampling_rate;
            valid_burst_end = valid_spikes(end) / sampling_rate;
            valid_burst_duration = valid_burst_end - valid_burst_start;
    
            % Check if the remaining spikes still form a valid burst
            if n_valid_spikes >= N_min && valid_burst_duration >= T_min && valid_burst_duration <= T_max
                bursts{end + 1} = valid_spikes;
                last_burst_end = valid_burst_end;  % Update last burst end time
            end
        end
    end

    % Calculate average burst firing rate per minute
    total_time = length(spike_train) / sampling_rate;
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

    % Calculate burst rate signal
    burst_rate_signal = zeros(1, length(spike_train));
    for i = 1:length(bursts)
        burst = bursts{i};
        if ~isempty(burst)
            burst_center = round(mean([burst(1), burst(end)]));
            burst_rate_signal(burst_center) = 1;
        end
    end
    
    % Downsample spike_train to 1000 Hz while preserving all spikes
    target_sampling_rate = 1000;
    downsample_factor = round(sampling_rate / target_sampling_rate);
    downsampled_length = ceil(length(burst_rate_signal) / downsample_factor);
    downsampled_burst_rate_signal = zeros(1, downsampled_length);
    for i = 1:downsampled_length
        start_idx = (i - 1) * downsample_factor + 1;
        end_idx = min(i * downsample_factor, length(burst_rate_signal));
        downsampled_burst_rate_signal(i) = any(burst_rate_signal(start_idx:end_idx));
    end
    
    % Create a boxcar kernel for smoothing the burst rate signal
    window_duration = 10;  % Window duration in seconds
    window_samples = round(window_duration * target_sampling_rate);
    boxcar_kernel = ones(1, window_samples) / window_samples;
    
    % Apply zero-phase filtering to obtain the burst rate signal
    burst_rate_signal = filtfilt(boxcar_kernel, 1, downsampled_burst_rate_signal);
    burst_rate_signal = burst_rate_signal * 60;  % Convert to bursts per minute
    
    % Plot the burst rate signal
    time_vector = (1:length(burst_rate_signal)) / target_sampling_rate;
    figure;
    plot(time_vector, burst_rate_signal, 'LineWidth', 2, 'Color', [0.5 0.5 0.5]);
    xlabel('Time (s)', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Burst Rate (bursts/min)', 'FontSize', 14, 'FontWeight', 'bold');
    title('Burst Rate Signal', 'FontSize', 16, 'FontWeight', 'bold');
    set(gca, 'FontSize', 12, 'FontWeight', 'bold', 'TickDir', 'out', 'Box', 'off');
 

end
