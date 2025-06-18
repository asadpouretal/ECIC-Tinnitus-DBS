function plot_average_firing_rate_group(parent_folder, params)
    % Define parameters
    original_sampling_rate = params.down_sampled_FR_frequency; % Hz
    downsample_factor = params.downsample_factor;  % Reduce by a factor of 50 (from 5000 Hz to 100 Hz)
    stim_duration = 60; % seconds (gray area)
    signal_length = 300; % seconds
    
    % Define paths to the Before and After stimulation subfolders for both groups
    control_before_folder = fullfile(parent_folder, 'Control', 'Before stimulation');
    tinnitus_before_folder = fullfile(parent_folder, 'Tinnitus', 'Before stimulation');
    tinnitus_after_folder = fullfile(parent_folder, 'Tinnitus', 'After stimulation');
    
    control_after_folder = fullfile(parent_folder, 'Control', 'After stimulation');
    
    % Load the firing rates for both groups
    control_firing_before = load_data(control_before_folder, signal_length);
    tinnitus_firing_before = load_data(tinnitus_before_folder, signal_length);
    tinnitus_firing_after = load_data(tinnitus_after_folder, signal_length);
    
    control_firing_after = load_data(control_after_folder, signal_length);
    
    % Downsample the firing rates
    tinnitus_firing_before_downsampled = downsample_data(tinnitus_firing_before, downsample_factor);
    tinnitus_firing_after_downsampled = downsample_data(tinnitus_firing_after, downsample_factor);
    control_firing_before_downsampled = downsample_data(control_firing_before, downsample_factor);
    control_firing_after_downsampled = downsample_data(control_firing_after, downsample_factor);

    % Create time vectors for downsampled data
    time_vector_before = create_time_vector(size(tinnitus_firing_before_downsampled, 2), original_sampling_rate, downsample_factor);
    time_vector_after = create_time_vector(size(tinnitus_firing_after_downsampled, 2), original_sampling_rate, downsample_factor) + signal_length + stim_duration;




    % Flatten all time points across all rats
    data_control_before = control_firing_before_downsampled(:);
    data_tinnitus_before = tinnitus_firing_before_downsampled(:);
    data_control_after = control_firing_after_downsampled(:);
    data_tinnitus_after = tinnitus_firing_after_downsampled(:);
    
    % Define x positions with sufficient spacing
    x_before = 1;
    x_after = 2;
    offset = 0.08;
    
    % Estimate plot range excluding outliers (1st–99th percentile)
    all_vals = [data_control_before; data_tinnitus_before; data_control_after; data_tinnitus_after];
    ylims = prctile(all_vals, [1 98]);
    
    % Start plot
    figure('Units','normalized','Position',[0.3, 0.3, 0.2, 0.3]); hold on;
    
    % Plot each box with reduced width and no outliers
    boxchart(repelem(x_before - offset, numel(data_control_before))', data_control_before, ...
        'BoxFaceColor', [0 0 1], 'LineWidth', 1.2, 'MarkerStyle', 'none', 'BoxWidth', 0.15);
    
    boxchart(repelem(x_before + offset, numel(data_tinnitus_before))', data_tinnitus_before, ...
        'BoxFaceColor', [1 0 0], 'LineWidth', 1.2, 'MarkerStyle', 'none', 'BoxWidth', 0.15);
    
    boxchart(repelem(x_after - offset, numel(data_control_after))', data_control_after, ...
        'BoxFaceColor', [0 0 1], 'LineWidth', 1.2, 'MarkerStyle', 'none', 'BoxWidth', 0.15);
    
    boxchart(repelem(x_after + offset, numel(data_tinnitus_after))', data_tinnitus_after, ...
        'BoxFaceColor', [1 0 0], 'LineWidth', 1.2, 'MarkerStyle', 'none', 'BoxWidth', 0.15);
    
    % Set x-axis
    set(gca, 'XTick', [x_before, x_after], 'XTickLabel', {'Before', 'After'}, ...
                 'FontSize', 16, ...
                'FontWeight', 'bold', ...
                'Box', 'off', ...
                'TickDir', 'out');
    % ylabel('Firing Rate (Hz)', 'FontSize', 16, 'FontWeight', 'bold');
    xlim([0.5 2.5]);
    ylim(ylims);  % set y-limits excluding extreme outliers
    
    % Compute per-rat means
    mean_control_before = mean(control_firing_before_downsampled, 2);   % 6x1
    mean_control_after  = mean(control_firing_after_downsampled, 2);    % 7x1
    mean_tinnitus_before = mean(tinnitus_firing_before_downsampled, 2);
    mean_tinnitus_after  = mean(tinnitus_firing_after_downsampled, 2);

    % === Before Comparison ===
    % Normalize data
    ctrl_b_z = (mean_control_before - mean(mean_control_before)) / std(mean_control_before);
    tin_b_z  = (mean_tinnitus_before - mean(mean_tinnitus_before)) / std(mean_tinnitus_before);
    
    % Normality test
    [h_ctrl_b, p_ctrl_b_norm] = kstest(ctrl_b_z);
    [h_tin_b,  p_tin_b_norm]  = kstest(tin_b_z);
    
    if ~h_ctrl_b && ~h_tin_b
        [~, p_before] = ttest2(mean_control_before, mean_tinnitus_before);
        test_used_before = 'unpaired t-test';
    else
        p_before = ranksum(mean_control_before, mean_tinnitus_before);
        test_used_before = 'Mann–Whitney U (ranksum)';
    end
    
    % === After Comparison ===
    ctrl_a_z = (mean_control_after - mean(mean_control_after)) / std(mean_control_after);
    tin_a_z  = (mean_tinnitus_after - mean(mean_tinnitus_after)) / std(mean_tinnitus_after);
    
    [h_ctrl_a, p_ctrl_a_norm] = kstest(ctrl_a_z);
    [h_tin_a,  p_tin_a_norm]  = kstest(tin_a_z);
    
    if ~h_ctrl_a && ~h_tin_a
        [~, p_after] = ttest2(mean_control_after, mean_tinnitus_after);
        test_used_after = 'unpaired t-test';
    else
        p_after = ranksum(mean_control_after, mean_tinnitus_after);
        test_used_after = 'Mann–Whitney U (ranksum)';
    end
    
    % Display results
    fprintf('Control vs Tinnitus (Before): %s, p = %.4g (normality: ctrl=%.4g, tin=%.4g)\n', ...
        test_used_before, p_before, p_ctrl_b_norm, p_tin_b_norm);
    fprintf('Control vs Tinnitus (After):  %s, p = %.4g (normality: ctrl=%.4g, tin=%.4g)\n', ...
        test_used_after,  p_after,  p_ctrl_a_norm, p_tin_a_norm);    
    
    % === CONTROL: Test for normality and perform UNPAIRED test ===
    [h_ctrl_before, p_ctrl_before_norm] = kstest((mean_control_before - mean(mean_control_before)) / std(mean_control_before));
    [h_ctrl_after, p_ctrl_after_norm] = kstest((mean_control_after - mean(mean_control_after)) / std(mean_control_after));
    
    if ~h_ctrl_before && ~h_ctrl_after
        [~, p_control_ba] = ttest2(mean_control_before, mean_control_after);
        test_used_control = 'unpaired t-test';
    else
        p_control_ba = ranksum(mean_control_before, mean_control_after);
        test_used_control = 'Mann–Whitney U (ranksum)';
    end
    
    % === TINNITUS: check if it's still paired (assumed so here) ===
    if size(mean_tinnitus_before, 1) == size(mean_tinnitus_after, 1)
        diff_tinnitus = mean_tinnitus_after - mean_tinnitus_before;
        h_tin = kstest((diff_tinnitus - mean(diff_tinnitus)) / std(diff_tinnitus));
        if ~h_tin
            [~, p_tinnitus_ba] = ttest(mean_tinnitus_before, mean_tinnitus_after);
            test_used_tinnitus = 'paired t-test';
        else
            p_tinnitus_ba = signrank(mean_tinnitus_before, mean_tinnitus_after);
            test_used_tinnitus = 'Wilcoxon signed-rank';
        end
    else
        warning('Tinnitus group also unpaired – adjust accordingly if needed.');
    end
    
    % Show results
    fprintf('[Control] %s: p = %.4g\n', test_used_control, p_control_ba);
    fprintf('[Tinnitus] %s: p = %.4g\n', test_used_tinnitus, p_tinnitus_ba);
        
    % Vertical spacing
    y_sig = ylims(2) - 0.03 * range(ylims);           % For between-group comparison
    y_sig_ba = y_sig - 0.01 * range(ylims);           % For within-group comparison (higher)
    y_sig_ba_tinnitus = y_sig - 0.02 * range(ylims);           % For within-group comparison (higher)
    y_offset = 0.01 * range(ylims);
    
    % Tinnitus vs Control comparisons
    if p_before < 0.05
        plot([x_before - offset, x_before + offset], [y_sig, y_sig], '-k', 'LineWidth', 1.5);
        text(x_before, y_sig + y_offset, get_star(p_before), ...
            'HorizontalAlignment', 'center', 'FontSize', 22, 'FontWeight', 'bold');
    end
    if p_after < 0.05
        plot([x_after - offset, x_after + offset], [y_sig, y_sig], '-k', 'LineWidth', 1.5);
        text(x_after, y_sig + y_offset, get_star(p_after), ...
            'HorizontalAlignment', 'center', 'FontSize', 22, 'FontWeight', 'bold');
    end
    
    % Within-group Before vs After comparisons
    if p_control_ba < 0.05
        plot([x_before - offset, x_after - offset], [y_sig_ba, y_sig_ba], 'Color', [0 0 1], 'LineWidth', 1.5);
        text(x_before - 0.15 + (x_after - x_before)/2, y_sig_ba + y_offset, get_star(p_control_ba), ...
            'HorizontalAlignment', 'center', 'Color', [0 0 1], 'FontSize', 22, 'FontWeight', 'bold');
    end
    if p_tinnitus_ba < 0.05
        plot([x_before + offset, x_after + offset], [y_sig_ba_tinnitus, y_sig_ba_tinnitus], 'Color', [1 0 0], 'LineWidth', 1.5);
        text(x_before + 0.1 + (x_after - x_before)/2, y_sig_ba_tinnitus - y_offset *5, get_star(p_tinnitus_ba), ...
            'HorizontalAlignment', 'center', 'Color', [1 0 0], 'FontSize', 22, 'FontWeight', 'bold');
    end

    % Plot the data
    % Compute means and confidence intervals for plotting
    [mean_tinnitus_before, ci_tinnitus_before] = mean_ci(tinnitus_firing_before_downsampled);
    [mean_tinnitus_after, ci_tinnitus_after] = mean_ci(tinnitus_firing_after_downsampled);
    [mean_control_before, ci_control_before] = mean_ci(control_firing_before_downsampled);
    [mean_control_after, ci_control_after] = mean_ci(control_firing_after_downsampled);

    figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
    hold on;
    shadedErrorBar(time_vector_before, mean_control_before, ci_control_before, {'-b', 'LineWidth', 2}, {});
    shadedErrorBar(time_vector_before, mean_tinnitus_before, ci_tinnitus_before, {'-r', 'LineWidth', 2}, {});
    fill([signal_length, signal_length + stim_duration, signal_length + stim_duration, signal_length], ...
        [min(ylim), min(ylim), max(ylim), max(ylim)], [0.8, 0.8, 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    shadedErrorBar(time_vector_after, mean_control_after, ci_control_after, {'-b', 'LineWidth', 2}, {});
    shadedErrorBar(time_vector_after, mean_tinnitus_after, ci_tinnitus_after, {'-r', 'LineWidth', 2}, {});

    % Kruskal-Wallis test and Rank-Biserial Correlation effect size
    effect_size_thresholds = [0.2, 0.5, 0.8]; % Thresholds for small, medium, large effect sizes
    for t = 1:size(tinnitus_firing_before_downsampled, 2)
        [p, ~] = kruskalwallis([tinnitus_firing_before_downsampled(:, t); control_firing_before_downsampled(:, t)], ...
            [ones(size(tinnitus_firing_before_downsampled, 1), 1); 2 * ones(size(control_firing_before_downsampled, 1), 1)], ...
            'off');
        if p < 0.05
            effect_size = rank_biserial_correlation(tinnitus_firing_before_downsampled(:, t), control_firing_before_downsampled(:, t));
            color = assign_color(effect_size, effect_size_thresholds);
            scatter(time_vector_before(t), min(ylim) + 0.1 * abs(min(ylim)), 50, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'none');
        end
    end
    for t = 1:size(tinnitus_firing_after_downsampled, 2)
        [p, ~] = kruskalwallis([tinnitus_firing_after_downsampled(:, t); control_firing_after_downsampled(:, t)], ...
            [ones(size(tinnitus_firing_after_downsampled, 1), 1); 2 * ones(size(control_firing_after_downsampled, 1), 1)], ...
            'off');
        if p < 0.05
            effect_size = rank_biserial_correlation(tinnitus_firing_after_downsampled(:, t), control_firing_after_downsampled(:, t));
            color = assign_color(effect_size, effect_size_thresholds);
            scatter(time_vector_after(t), min(ylim) + 0.1 * abs(min(ylim)), 50, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'none');
        end
    end

    % Manually adjust x-ticks and labels
    x_ticks_before = 0:100:signal_length;  % X-ticks for before stimulation
    x_ticks_after = signal_length + stim_duration + (0:100:signal_length);  % X-ticks for after stimulation

    xticks([x_ticks_before x_ticks_after]);  % Set combined x-ticks

    % Create new labels: reset after stimulation
    xtick_labels_before = string(x_ticks_before);  % Labels for before stimulation
    xtick_labels_after = string(0:100:signal_length);  % Reset labels after stimulation
    xticklabels([xtick_labels_before xtick_labels_after]);  % Set the combined labels    

    % Add labels and finalize plot
    set(gca, 'FontSize', 16, 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out');
    xlabel('Time (s)', 'FontSize', 18, 'FontWeight', 'bold');
    ylabel('Firing Rate (Hz)', 'FontSize', 18, 'FontWeight', 'bold');
    legend({'Control', 'Tinnitus'}, 'Location', 'northeast');
    xlim([0, 2 * signal_length + stim_duration]);
    hold off;

    % Helper functions
    function data = load_data(folder, signal_length)
        files = dir(fullfile(folder, 'Rat*', 'Results', 'results.mat'));
        data = [];
        for i = 1:length(files)
            load(fullfile(files(i).folder, 'results.mat'), 'results');
            if length(results.downsampled_firing_rate_signal) == signal_length * results.params.down_sampled_FR_frequency
                data = [data; results.downsampled_firing_rate_signal];
            end
        end
    end

    function data_downsampled = downsample_data(data, factor)
        data_downsampled = data(:, 1:factor:end);
    end

    function time_vector = create_time_vector(data_length, original_rate, downsample_factor)
        time_vector = (0:data_length - 1) * (downsample_factor / original_rate);
    end

    function [mean_data, ci_data] = mean_ci(data)
        mean_data = mean(data, 1);
        ci_data = 1.96 * std(data, 0, 1) / sqrt(size(data, 1));
    end

    function rbc = rank_biserial_correlation(group1, group2)
        % Calculate the Rank-Biserial Correlation
        ranks = tiedrank([group1; group2]); % Rank all data together
        n1 = length(group1);
        n2 = length(group2);
        rank1_mean = mean(ranks(1:n1));
        rank2_mean = mean(ranks(n1+1:end));
        rbc = (rank1_mean - rank2_mean) / (n1 + n2);
    end

    function color = assign_color(effect_size, thresholds)
        if abs(effect_size) < thresholds(1)
            color = [0, 0.5, 0]; % Dark Green for low effect size
        elseif abs(effect_size) < thresholds(2)
            color = [1, 0.65, 0]; % Orange for medium effect size
        else
            color = [0, 0.5, 0.5]; % Teal for high effect size
        end
    end

    % Helper function for star annotation
    function star = get_star(p)
        if p < 0.001
            star = '***';
        elseif p < 0.01
            star = '**';
        else
            star = '*';
        end
    end
end
