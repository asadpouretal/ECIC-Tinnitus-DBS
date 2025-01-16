function multiplier = compute_multiplier_histogram(data)
    % Compute the histogram
    [counts, edges] = histcounts(data, 100);  % Adjust bin number (100 here) as needed

    % Smooth the histogram to reduce noise
    windowSize = 5;  % Adjust as necessary
    smoothed_counts = conv(counts, ones(1,windowSize)/windowSize, 'same');

    % Find local minima
    diffs = diff(smoothed_counts);
    minima = find(diffs(1:end-1) > 0 & diffs(2:end) < 0) + 1;

    % Find local maxima
    maxima = find(diffs(1:end-1) < 0 & diffs(2:end) > 0) + 1;

    % If not enough peaks are found, return a default multiplier (e.g., 4.5)
    if length(minima) < 1 || length(maxima) < 2
        multiplier = 4.5;
        return;
    end

    % Find the threshold by taking the bin edge corresponding to the minimum
    % between the two peaks
    threshold = edges(minima(1));

    % Calculate the multiplier based on MAD
    multiplier = (threshold - median(data)) / mad(data, 1);
end
