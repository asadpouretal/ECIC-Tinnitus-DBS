function mdaFile = write_mda(data, dirPath, sampleRate)
    % Write .mda file using the provided writemda function
    mdaFile = fullfile(dirPath, 'raw.mda');
    writemda(data, mdaFile, 'float32');

    % Create geom.csv file
    geomFile = fullfile(dirPath, 'geom.csv');
    fid = fopen(geomFile, 'w');
    fprintf(fid, '0, 0\n');
    fclose(fid);

    % Create params.json file
    params = struct('samplerate', sampleRate, 'spike_sign', -1);
    jsonText = jsonencode(params);
    paramsFile = fullfile(dirPath, 'params.json');
    fid = fopen(paramsFile, 'w');
    fprintf(fid, jsonText);
    fclose(fid);

    % Create firings_true.mda file
    firingsFile = fullfile(dirPath, 'firings_true.mda');
    fid = fopen(firingsFile, 'w');
    fwrite(fid, -3, 'int32'); % data type code for float32
    fwrite(fid, 2, 'int32'); % number of dimensions
    fwrite(fid, [3, 0], 'int32'); % dimensions (3 rows, 0 columns)
    fclose(fid);

    % Create group.csv file
    groupFile = fullfile(dirPath, 'group.csv');
    fid = fopen(groupFile, 'w');
    fprintf(fid, '1\n');
    fclose(fid);
end