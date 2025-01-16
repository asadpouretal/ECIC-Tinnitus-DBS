function filtered_data = bandpass_filter_EEGLAB(data, low_cutoff, high_cutoff, Fs)
    % BANDPASS_FILTER Filter the data with a bandpass filter using EEGLAB
    % 
    % Input:
    % data       - Original data
    % low_cutoff - Lower frequency cutoff (Hz)
    % high_cutoff- Upper frequency cutoff (Hz)
    % Fs         - Sampling frequency (Hz)
    % 
    % Output:
    % filtered_data - Filtered data

    % Ensure EEGLAB is in the path
    if exist('pop_eegfiltnew', 'file') ~= 2
        error('EEGLAB must be installed and added to the MATLAB path.');
    end
    
    % Create a temporary EEG structure for filtering
    EEG = eeg_emptyset();
    EEG.data = data;
    EEG.srate = Fs;
    EEG.nbchan = 1;
    EEG.pnts = length(data);
    EEG.trials = 1;
    
    % Apply bandpass filter using EEGLAB's pop_eegfiltnew
    EEG = pop_eegfiltnew(EEG, low_cutoff, high_cutoff);

    % Extract the filtered data
    filtered_data = EEG.data;
end
