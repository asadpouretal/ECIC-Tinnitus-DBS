% Script to plot average firing rate, burst rate, and histograms

% Use a GUI to get the parent folder
parent_folder = uigetdir('', 'Select the Parent Folder Containing "Before stimulation" and "After stimulation" Folders');

% Check if a folder was selected
if parent_folder == 0
    disp('No folder selected. Exiting script.');
    return;
end

% Call the functions with the selected parent folder
plot_average_firing_rate(parent_folder);
plot_average_burst_rate(parent_folder);
compare_isi_histograms(parent_folder);
% compare_isi_pdf(parent_folder);