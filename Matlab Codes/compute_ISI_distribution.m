function [ISI, meanISI] = compute_ISI_distribution(spike_train, sampling_rate)
    % Find the indices of the spikes
    spike_indices = find(spike_train);

    % Calculate the Inter-Spike Intervals (ISIs) in milliseconds
    ISI = diff(spike_indices) / sampling_rate * 1000;

    % Calculate statistics
    meanISI = mean(ISI);
    stdISI = std(ISI);
    cvISI = stdISI / meanISI; % Coefficient of variation of ISI
    
    % Plot the ISI histogram with 5 ms bins
    bin_width_ms = 5; % 5 milliseconds
    max_ISI = max(ISI);
    bin_edges = 0:bin_width_ms:max_ISI; % Bin edges for the histogram
    
    figure;
    histogram(ISI, 'BinEdges', bin_edges, 'Normalization', 'probability', 'FaceColor', [0.5, 0.5, 0.5]); % Gray color for the histogram, increased number of bins
    xlabel('Inter-Spike Interval (ms)', 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Probability', 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold');
    title(['ISI Distribution (Average ISI: ', num2str(meanISI, '%.3f'), ' ms)'], 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');
    set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.5, 'TickLength', [0.02, 0.02]); % Clean and clear axis style
    xlim([0 100]); % Set x-axis limits to [0, 100] ms
end
