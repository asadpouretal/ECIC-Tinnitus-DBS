function compare_isi_histograms(parent_folder)
    % Define the paths to the before and after stimulation folders
    before_folder = fullfile(parent_folder, 'Before stimulation');
    after_folder = fullfile(parent_folder, 'After stimulation');
    
    % Get list of rats before and after stimulation
    rats_before = dir(fullfile(before_folder, 'Rat*'));
    rats_after = dir(fullfile(after_folder, 'Rat*'));

    % Initialize arrays to collect ISI data
    ISIs_before = [];
    ISIs_after = [];

    % Collect ISIs before stimulation
    for i = 1:length(rats_before)
        load(fullfile(rats_before(i).folder, rats_before(i).name, 'Results', 'results.mat'), 'results');
        ISIs_before = [ISIs_before; results.ISIs(:)];
    end

    % Collect ISIs after stimulation
    for i = 1:length(rats_after)
        load(fullfile(rats_after(i).folder, rats_after(i).name, 'Results', 'results.mat'), 'results');
        ISIs_after = [ISIs_after; results.ISIs(:)];
    end
    % Determine the bin edges for 0.1 second bin length
    bin_edges = 0:5:max([ISIs_before; ISIs_after]);

    % Plot ISI histograms before and after stimulation
    figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.6, 0.6]);
    subplot(2, 1, 1);
    histogram(ISIs_before, bin_edges, 'Normalization', 'probability', 'FaceColor', [0.5, 0.5, 0.5]);
    xlim([0 100]); % Set x-axis limits to [0, 1
    ylim([0 1]);
    title('ISI Histogram Before Stimulation');
    % xlabel('Inter-Spike Interval (s)');
    ylabel('Probability');
    % Set custom axes properties
    set(gca, 'FontSize', 12, 'FontWeight', 'bold', 'TickDir', 'out', 'Box', 'off', ...
             'LineWidth', 1.5, 'TickLength', [0.02, 0.02]);     

    subplot(2, 1, 2);
    histogram(ISIs_after, bin_edges, 'Normalization', 'probability', 'FaceColor', [0.5, 0.5, 0.5]);
    xlim([0 100]); % Set x-axis limits to [0, 1]
    ylim([0 1]);
    title('ISI Histogram After Stimulation');
    xlabel('Inter-Spike Interval (ms)');
    ylabel('Probability');

    % Set custom axes properties
    set(gca, 'FontSize', 12, 'FontWeight', 'bold', 'TickDir', 'out', 'Box', 'off', ...
             'LineWidth', 1.5, 'TickLength', [0.02, 0.02]);    
end
