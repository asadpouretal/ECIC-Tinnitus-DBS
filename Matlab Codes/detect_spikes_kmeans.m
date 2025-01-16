function spike_times_kmeans = detect_spikes_kmeans(data, num_clusters)
    % Extract features: amplitude and slope
    amplitude = data(2:end-1);
    slope = data(3:end) - data(1:end-2);
    
    % Create feature matrix
    features = [amplitude', slope'];
    
    % Perform k-means clustering
    [idx, ~] = kmeans(features, num_clusters);
    
    % Assuming the cluster with the highest centroid amplitude is the spike cluster
    [~, spike_cluster] = max(cellfun(@(v) mean(v), arrayfun(@(i) features(idx == i, 1), unique(idx), 'UniformOutput', false)));
    
    % Get the spike times
    spike_times_kmeans = find(idx == spike_cluster) + 1;  % Adding 1 to account for the 1st data point we skipped
end
