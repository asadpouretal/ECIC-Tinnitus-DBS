function filtered_data = bandpass_filter(data, low_cutoff, high_cutoff, Fs)
    % BANDPASS_FILTER Filter the data with a bandpass filter
    % 
    % Input:
    % data       - Original data
    % low_cutoff - Lower frequency cutoff
    % high_cutoff- Upper frequency cutoff
    % Fs         - Sampling frequency
    % 
    % Output:
    % filtered_data - Filtered data
    
    % Design the bandpass filter
    [b, a] = butter(4, [low_cutoff, high_cutoff] / (Fs/2));
    
    % Apply the filter to the data
    filtered_data = filtfilt(b, a, data);
end
