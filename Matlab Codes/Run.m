clear; close all;
% Restore the default MATLAB search path
restoredefaultpath;
current_file_path = mfilename('fullpath');
[current_folder, ~, ~] = fileparts(current_file_path);
% Add related toolboxes
% addpath(('C:\Data\21-07-2024\LDA-DP-main'));
addpath(genpath(fullfile(current_folder, 'wave_clus-master')));
addpath((fullfile(current_folder, 'filtering')));

% Ask user for number of files to analyze
num_files = str2double(inputdlg('Enter the number of files to analyze:', 'Number of Files', 1, {'1'}));

% Initialize cell arrays to store file names and paths
file_names = cell(1, num_files);
main_paths = cell(1, num_files);

% GUI for file selection
for i = 1:num_files
    [file_names{i}, main_paths{i}] = uigetfile('*.Stream', sprintf('Select file %d', i), 'C:\Data\21-07-2024\Tinnitus');
    if isequal(file_names{i}, 0) || isequal(main_paths{i}, 0)
        disp('User pressed cancel');
        return;
    end
end

% GUI for user input
prompt = {'Low Cutoff Frequency (Hz)', 'High Cutoff Frequency (Hz)', 'Window Duration (s)', ...
          'Maximum Burst Duration (s)', 'Maximum Interspike Interval at Burst Start (s)', 'Maximum Within-Burst Interspike Interval (s)', ...
          'Minimum Interval Between Bursts (s)', 'Minimum Burst Duration (s)', 'Minimum Number of Spikes Comprising a Burst', 'MAD Multiplier'};
dlg_title = 'Input Parameters';
num_lines = 1;
defaultans = {'300', '6000', '1', '310', '0.5', '0.5', '1', '0.005', '2', '8'};
answer = inputdlg(prompt, dlg_title, num_lines, defaultans);

% Store parameters in a structure
params.low_cutoff = str2double(answer{1});
params.high_cutoff = str2double(answer{2});
params.window_duration = str2double(answer{3});
params.T_max = str2double(answer{4});
params.ISI_start_max = str2double(answer{5});
params.ISI_within_max = str2double(answer{6});
params.T_min_between = str2double(answer{7});
params.T_min = str2double(answer{8});
params.N_min = str2double(answer{9});
params.MAD_multiplier = str2double(answer{10});
params.down_sampled_FR_frequency = 5000; % down-sampled frequency for firing rate (Hz)
params.downsample_factor = 50;  % Reduce by a factor of 50 (from 5000 Hz to 100 Hz)
params.down_sampled_BR_frequency = 1000; % down-sampled frequency for burst rate (Hz)
params.min_ISI = 1;   % Minimum Inter-spike interval (ms)
params.pre_peak_time = 0.001; % 1 ms before the peak for spike sorting
params.post_peak_time = 0.001; % 1 ms after the peak for spike sorting
% sampling_rate = 50000;

% Run sequentially
disp('Running sequentially.');
for i = 1:num_files
    results(i) = analyze_spike_data(main_paths{i}, file_names{i}, params);
end


% 
parent_folder = 'C:\Users\aaa210\OneDrive - University of Sussex\Research projects\Bimarestan Rasoul\Akbarnejad Single\New Device\Analysed data';
plot_average_firing_rate_group(parent_folder, params);
% plot_average_burst_rate(parent_folder);
compare_isi_histograms_group(parent_folder);
compare_isi_pdf(parent_folder);