function prmFile = create_prm_file(recordingFile, samplingRate)
    % Create a .prm file for IronClust
    [path, name, ~] = fileparts(recordingFile);
    prmFile = fullfile(path, [name, '.prm']);
    
    fid = fopen(prmFile, 'w');
    fprintf(fid, 'vcFile = ''%s''\n', recordingFile);
    fprintf(fid, 'sRateHz = %d\n', samplingRate);
    fprintf(fid, 'nChans = 1\n'); % Assuming single channel
    fprintf(fid, 'dtype = ''float32''\n'); % Ensure this matches your data type
    fprintf(fid, 'hp_filtered = 0\n');
    fprintf(fid, 'vcDataType = ''float32''\n');
    fprintf(fid, 'nBytes_data = 4\n');
    fprintf(fid, 'header_offset = 0\n');
    fprintf(fid, 'vcFile_prm = ''%s''\n', prmFile);
    fclose(fid);
end