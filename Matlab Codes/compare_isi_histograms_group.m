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

    % Collect per-rat total ISIs (i.e., spike counts - 1)
    tinnitus_counts_before = zeros(length(tinnitus_before_rats), 1);
    tinnitus_counts_after = zeros(length(tinnitus_after_rats), 1);
    
    for i = 1:length(tinnitus_before_rats)
        load(fullfile(tinnitus_before_rats(i).folder, tinnitus_before_rats(i).name, 'Results', 'results.mat'), 'results');
        tinnitus_counts_before(i) = length(results.ISIs);  % ISI count = spike count - 1
    end
    
    for i = 1:length(tinnitus_after_rats)
        load(fullfile(tinnitus_after_rats(i).folder, tinnitus_after_rats(i).name, 'Results', 'results.mat'), 'results');
        tinnitus_counts_after(i) = length(results.ISIs);
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

    % Statistical comparison: Kolmogorov–Smirnov tests
    [ks_h_before, ks_p_before] = kstest2(tinnitus_ISIs_before, control_ISIs_before);
    [ks_h_after, ks_p_after] = kstest2(tinnitus_ISIs_after, control_ISIs_after);
    
    fprintf('KS Test (Before Stimulation): p = %.4g\n', ks_p_before);
    fprintf('KS Test (After Stimulation):  p = %.4g\n', ks_p_after);
    
    % Short ISI threshold (e.g., < 5 ms)
    threshold_ms = 5;
    short_tinnitus_before = sum(tinnitus_ISIs_before < threshold_ms);
    short_control_before = sum(control_ISIs_before < threshold_ms);
    short_tinnitus_after = sum(tinnitus_ISIs_after < threshold_ms);
    short_control_after = sum(control_ISIs_after < threshold_ms);
    
    % Total counts
    total_tinnitus_before = numel(tinnitus_ISIs_before);
    total_control_before = numel(control_ISIs_before);
    total_tinnitus_after = numel(tinnitus_ISIs_after);
    total_control_after = numel(control_ISIs_after);
    
    % Proportions
    prop_tin_before = short_tinnitus_before / total_tinnitus_before;
    prop_ctrl_before = short_control_before / total_control_before;
    prop_tin_after = short_tinnitus_after / total_tinnitus_after;
    prop_ctrl_after = short_control_after / total_control_after;
    
    fprintf('Proportion of ISIs < %d ms (Before): Tinnitus = %.2f%%, Control = %.2f%%\n', ...
        threshold_ms, prop_tin_before*100, prop_ctrl_before*100);
    fprintf('Proportion of ISIs < %d ms (After):  Tinnitus = %.2f%%, Control = %.2f%%\n', ...
        threshold_ms, prop_tin_after*100, prop_ctrl_after*100);
    
    % Optional: Chi-square test on short ISI counts
    [~, chi_p_before, ~] = crosstab([ones(short_tinnitus_before,1); zeros(short_control_before,1)], ...
                                     [repmat("Tinnitus", short_tinnitus_before, 1); repmat("Control", short_control_before, 1)]);
                                 
    [~, chi_p_after, ~] = crosstab([ones(short_tinnitus_after,1); zeros(short_control_after,1)], ...
                                    [repmat("Tinnitus", short_tinnitus_after, 1); repmat("Control", short_control_after, 1)]);
    
    fprintf('Chi-square (short ISIs < %d ms): Before = %.4g, After = %.4g\n', threshold_ms, chi_p_before, chi_p_after);
    
    % Normality test
    diff_counts = tinnitus_counts_after - tinnitus_counts_before;
    [h_norm, p_norm] = kstest((diff_counts - mean(diff_counts)) / std(diff_counts));
    
    if ~h_norm
        [~, p_spikecount] = ttest(tinnitus_counts_before, tinnitus_counts_after);
        test_used = 'paired t-test';
    else
        p_spikecount = signrank(tinnitus_counts_before, tinnitus_counts_after);
        test_used = 'Wilcoxon signed-rank test';
    end
    
    fprintf('Spike count comparison (Tinnitus Before vs After): %s, p = %.4g\n', test_used, p_spikecount);

end
