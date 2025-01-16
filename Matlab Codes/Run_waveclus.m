clear; close all;

% Restore the default MATLAB search path
restoredefaultpath;
addpath(genpath('C:\Users\assad\OneDrive - Ulster University\Toolboxes\wave_clus-master'));
% Ask user for number of files to analyze
num_files = str2double(inputdlg('Enter the number of files to analyze:', 'Number of Files', 1, {'1'}));

% Initialize cell arrays to store file names and paths
file_names = cell(1, num_files);
main_paths = cell(1, num_files);

% GUI for file selection
for i = 1:num_files
    [file_names{i}, main_paths{i}] = uigetfile('*.Stream', sprintf('Select file %d', i));
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

i = 1;
file_fullpath = fullfile(main_paths{i}, file_names{i});
[folder_name, filename, ext] = fileparts(file_fullpath);

[info, data] = ImportStreamData(file_fullpath);
sampling_rate = extract_sampling_frequency(info);

output_file = fullfile(main_paths{i}, [filename '.mat']);

save(output_file, "data", '-v7.3');

param.stdmin = 4;
param.sr = sampling_rate;
param.detection = 'both';
Get_spikes(output_file,'par',param);
output_file_spike = fullfile(main_paths{i}, [filename '_spikes.mat']);
Do_clustering(output_file_spike)