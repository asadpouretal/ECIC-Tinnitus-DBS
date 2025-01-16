function threshold = compute_FDR_threshold(data, q)
    % Determines the spike detection threshold using FDR with empirical p-values

    num_permutations = 1000;  % Number of random permutations
    subsample_ratio = 0.1;  % Use 10% of data for each permutation; adjust as needed
    subsample_size = floor(subsample_ratio * length(data));

    max_values = zeros(num_permutations, 1);

    parfor i = 1:num_permutations  % Use 'parfor' for parallel computation
        idx = randsample(length(data), subsample_size);  % Random subsample
        permuted_data = data(idx(randperm(subsample_size)));
        max_values(i) = max(permuted_data);
    end

    % Sort the max values from the permutations
    sorted_max_values = sort(max_values);

    % Determine the threshold based on the desired FDR
    index = floor((1 - q) * num_permutations);
    if index < 1
        error('No appropriate threshold found.');
    end
    threshold = sorted_max_values(index);
end
