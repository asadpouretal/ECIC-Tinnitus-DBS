clear; close all;

% Restore the default MATLAB search path
restoredefaultpath;
addpath(('C:\Data\21-07-2024\LDA-DP-main'));
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

i = 1;
file_fullpath = fullfile(main_paths{i}, file_names{i});
[folder_name, filename, ext] = fileparts(file_fullpath);

[info, data] = ImportStreamData(file_fullpath);
sampling_rate = extract_sampling_frequency(info);


% Assuming your data is in a variable called 'dataVector'
analysed_folder = fullfile(folder_name, 'Sorted_LDA_DP');

% Check and create output directory if it does not exist
if ~exist(analysed_folder, 'dir')
    mkdir(analysed_folder);
end

Spikes = DetectWave(sampling_rate,data);
Sample_data=size(Spikes,1);

Dim_sub=5; %dim of feature subspace
numCluster0=4; %initial cluster num
flagMerge=1; %1:merge 0: non-merge


[Idx_sort,Idx_center]=ldadp_fuc(Spikes,Sample_data,Dim_sub,numCluster0,flagMerge);
