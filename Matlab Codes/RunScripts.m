clear; close all;

% Start a parallel pool with 16 workers
pool = gcp('nocreate');  % Check if there's an existing pool
if isempty(pool)
    parpool('local', 12);  % Start a new pool if none exists
end

main_path = 'C:\Users\assad\OneDrive - Ulster University\Research projects\Bimarestan Rasoul\Akbarnejad Single\New Device\22-08-2023';

file_name = 'Case 2 T first record before stmu.Stream';
file_fullpath = fullfile(main_path, file_name);


[info, data] = ImportStreamData(file_fullpath);
sampling_rate = extract_sampling_frequency(info);
low_cutoff = 300;       % Typical low cutoff for spike detection
high_cutoff = 6000; % Typical high cutoff for spike detection
total_duration = length(data) / sampling_rate;  % Replace with your sampling rate to get the recording duration in seconds
MAD_multiplier = 8; % compute_multiplier_histogram(filtered_data);
window_duration = 1; % in seconds
sigma_duration = 0.045;
isi_threshold = 0.010;
min_spikes_in_burst = 3;
% Define the parameters as recommended in the paper by Carol A. Bauer et al.
T_max = 310;            % Maximum allowable burst duration in seconds
ISI_start_max = 0.5;    % Maximum interspike interval at burst start in seconds
ISI_within_max = 0.5;   % Maximum within-burst interspike interval in seconds
T_min_between = 1;      % Minimum interval between bursts in seconds
T_min = 0.005;          % Minimum burst duration in seconds
N_min = 2;              % Minimum number of spikes comprising a burst

% Filter the data
filtered_data = bandpass_filter(data, low_cutoff, high_cutoff, sampling_rate);


neo_multiplier = 3.5; % Adjust based on your specific needs
[spike_times_MAD, spike_train] = calculate_MAD(filtered_data, MAD_multiplier);

% Estimate spontaneous firing rate
% [firing_rate_signal, avg_firing_rate] = compute_firing_rate_gaussian(spike_train, sampling_rate, sigma_duration);
% fprintf('The spontaneous firing rate is %.2f Hz\n', avg_firing_rate);
[firing_rate_signal, avg_firing_rate] = compute_firing_rate(spike_train, sampling_rate, window_duration);
fprintf('The spontaneous firing rate is %.2f Hz\n', avg_firing_rate);
[ISIs, avg_ISI] = compute_ISI_distribution(spike_train, sampling_rate);
fprintf('The spontaneous average ISI is %.2f s\n', avg_ISI);

% [bursts, avg_burst_firing_rate, burst_durations, intraburst_frequencies, burst_firing_rate] = detect_bursts_poisson_surprise(spike_train, sampling_rate);

[bursts, avg_burst_firing_rate, burst_durations, intraburst_frequencies, burst_firing_rate] = detect_bursts_bauer_et_al(spike_train, sampling_rate, 'T_max', T_max, 'ISI_start_max', ISI_start_max, 'ISI_within_max', ISI_within_max, 'T_min_between', T_min_between, 'T_min', T_min, 'N_min', N_min);



% Shut down the parallel pool
delete(gcp('nocreate'))