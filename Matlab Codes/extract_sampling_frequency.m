function Fs = extract_sampling_frequency(charArray)
    % EXTRACT_SAMPLING_FREQUENCY Extracts the sampling frequency from a character array
    % 
    % Input:
    % charArray - A character array containing information like 'SampleRate=1000 High pass filter=...'
    % 
    % Output:
    % Fs        - Extracted sampling frequency

    pattern = '(?<=SampleRate=)(\d+\.?\d*)(?=\s*High pass filter=)';
    sampleRateStr = regexp(charArray, pattern, 'match');

    if ~isempty(sampleRateStr)
        Fs = str2double(sampleRateStr{1});
    else
        error('Sampling frequency not found in the given character array.');
    end
end
