function compare_isi_histograms_group(parent_folder)
    % Define the paths to the before and after stimulation folders for both groups
    tinnitus_before_folder = fullfile(parent_folder, 'Tinnitus', 'Before stimulation');
    tinnitus_after_folder = fullfile(parent_folder, 'Tinnitus', 'After stimulation');
    control_before_folder = fullfile(parent_folder, 'Control', 'Before stimulation');
    control_after_folder = fullfile(parent_folder, 'Control', 'After stimulation');
    
    % Get list of rats before and after stimulation for both groups
    tinnitus_before_rats = dir(fullfile(tinnitus_before_folder, 'Rat*'));
    tinnitus_after_rats = dir(fullfile(tinnitus_after_folder, 'Rat*'));
    control_before_rats = dir(fullfile(control_before_folder, 'Rat*'));
    control_after_rats = dir(fullfile(control_after_folder, 'Rat*'));

    % Initialize arrays to collect ISI data
    tinnitus_ISIs_before = [];
    tinnitus_ISIs_after = [];
    control_ISIs_before = [];
    control_ISIs_after = [];

    % Collect ISIs before stimulation for tinnitus group
    for i = 1:length(tinnitus_before_rats)
        load(fullfile(tinnitus_before_rats(i).folder, tinnitus_before_rats(i).name, 'Results', 'results.mat'), 'results');
        tinnitus_ISIs_before = [tinnitus_ISIs_before; results.ISIs(:)];
    end

    % Collect ISIs after stimulation for tinnitus group
    for i = 1:length(tinnitus_after_rats)
        load(fullfile(tinnitus_after_rats(i).folder, tinnitus_after_rats(i).name, 'Results', 'results.mat'), 'results');
        tinnitus_ISIs_after = [tinnitus_ISIs_after; results.ISIs(:)];
    end

    % Collect ISIs before stimulation for control group
    for i = 1:length(control_before_rats)
        load(fullfile(control_before_rats(i).folder, control_before_rats(i).name, 'Results', 'results.mat'), 'results');
        control_ISIs_before = [control_ISIs_before; results.ISIs(:)];
    end

    % Collect ISIs after stimulation for control group
    for i = 1:length(control_after_rats)
        load(fullfile(control_after_rats(i).folder, control_after_rats(i).name, 'Results', 'results.mat'), 'results');
        control_ISIs_after = [control_ISIs_after; results.ISIs(:)];
    end

    % Determine the bin edges for 0.1 second bin length
    bin_edges = 0:5:max([tinnitus_ISIs_before; tinnitus_ISIs_after; control_ISIs_before; control_ISIs_after]);

    % Plot ISI histograms before and after stimulation for both groups
    figure1 = figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);

    % Before stimulation
    subplot(1, 2, 1);
    histogram(control_ISIs_before, bin_edges, 'Normalization', 'count', 'EdgeColor', 'b', 'FaceColor', 'none', 'FaceAlpha', 0.5, 'LineWidth', 1.5, 'DisplayName', 'Control');
    hold on;
    histogram(tinnitus_ISIs_before, bin_edges, 'Normalization', 'count', 'EdgeColor', 'r', 'FaceColor', 'none', 'FaceAlpha', 0.5, 'LineWidth', 1.5, 'DisplayName', 'Tinnitus');    
    hold off;
    xlim([0 100]);
    ylim([0 8000]);
%     title('ISI Histogram Before Stimulation');

    
    set(gca, 'FontSize', 15, 'FontWeight', 'bold', 'TickDir', 'out', 'Box', 'off', 'TickLength', [0.02, 0.02]); %, 'LineWidth', 1.5, 'TickLength', [0.02, 0.02]);
    xlabel('Inter-Spike Interval (ms)', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Spike Count', 'FontSize', 16, 'FontWeight', 'bold');

    % After stimulation
    subplot(1, 2, 2);
    histogram(control_ISIs_after, bin_edges, 'Normalization', 'count', 'EdgeColor', 'b', 'FaceColor', 'none', 'FaceAlpha', 0.5, 'LineWidth', 1.5, 'DisplayName', 'Control');
    hold on;
    histogram(tinnitus_ISIs_after, bin_edges, 'Normalization', 'count', 'EdgeColor', 'r', 'FaceColor', 'none', 'FaceAlpha', 0.5, 'LineWidth', 1.5, 'DisplayName', 'Tinnitus');
    hold off;
    xlim([0 100]);
    ylim([0 8000]);
%     title('ISI Histogram After Stimulation');
    
%     legend('show');
    set(gca, 'FontSize', 15, 'FontWeight', 'bold', 'TickDir', 'out', 'Box', 'off', 'YTickLabel', [], 'TickLength', [0.02, 0.02]); %, 'LineWidth', 1.5, 'TickLength', [0.02, 0.02]);
    xlabel('Inter-Spike Interval (ms)', 'FontSize', 16, 'FontWeight', 'bold');

    % Add global y-label
%     han = axes(figure1, 'visible', 'off'); 
%     han.YLabel.Visible = 'on';
%     ylabel(han, 'Probability', 'FontSize', 14, 'FontWeight', 'bold');
end
