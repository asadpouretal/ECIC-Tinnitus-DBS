function convert_vector_to_bin(dataVector, binFile)
    % Convert a vector to a .bin file and create a probe file
    % dataVector: the input vector data
    % binFile: the output .bin file name

    % Open file for writing
    fid = fopen(binFile, 'w');
    if fid == -1
        error('Cannot open file for writing: %s', binFile);
    end
    
    % Write data to file
    fwrite(fid, dataVector, 'int16'); % Change 'int16' if your data type is different
    
    % Close the file
    fclose(fid);
    
    fprintf('Data successfully written to %s\n', binFile);
    
    % Create the probe file name based on the bin file name
    [path, name, ~] = fileparts(binFile);
    prbFile = fullfile(path, [name, '.prb']);
    
    % Create the probe file content
    probeFileContent = [
        "channel_groups = {", ...
        "    0: {", ...
        "        'channels': [0],", ...
        "        'geometry': {0: [0, 0]}", ...
        "    }", ...
        "}"
    ];
    
    % Write the probe file
    fid = fopen(prbFile, 'w');
    if fid == -1
        error('Cannot open file for writing: %s', prbFile);
    end
    
    fprintf(fid, '%s\n', probeFileContent{:});
    fclose(fid);
    
    fprintf('Probe file successfully written to %s\n', prbFile);
end