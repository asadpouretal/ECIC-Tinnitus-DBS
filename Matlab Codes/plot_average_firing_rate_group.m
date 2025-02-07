function plot_average_firing_rate_group(parent_folder, params)
    % Define parameters
    original_sampling_rate = params.down_sampled_FR_frequency; % Hz
    downsample_factor = params.downsample_factor;  % Reduce by a factor of 50 (from 5000 Hz to 100 Hz)
    stim_duration = 60; % seconds (gray area)
    signal_length = 300; % seconds
    
    % Define paths to the Before and After stimulation subfolders for both groups
    tinnitus_before_folder = fullfile(parent_folder, 'Tinnitus', 'Before stimulation');
    tinnitus_after_folder = fullfile(parent_folder, 'Tinnitus', 'After stimulation');
    control_before_folder = fullfile(parent_folder, 'Control', 'Before stimulation');
    control_after_folder = fullfile(parent_folder, 'Control', 'After stimulation');
    
    % Load the firing rates for both groups
    tinnitus_firing_before = load_data(tinnitus_before_folder, signal_length);
    tinnitus_firing_after = load_data(tinnitus_after_folder, signal_length);
    control_firing_before = load_data(control_before_folder, signal_length);
    control_firing_after = load_data(control_after_folder, signal_length);
    
    % Downsample the firing rates
    tinnitus_firing_before_downsampled = downsample_data(tinnitus_firing_before, downsample_factor);
    tinnitus_firing_after_downsampled = downsample_data(tinnitus_firing_after, downsample_factor);
    control_firing_before_downsampled = downsample_data(control_firing_before, downsample_factor);
    control_firing_after_downsampled = downsample_data(control_firing_after, downsample_factor);

    % Create time vectors for downsampled data
    time_vector_before = create_time_vector(size(tinnitus_firing_before_downsampled, 2), original_sampling_rate, downsample_factor);
    time_vector_after = create_time_vector(size(tinnitus_firing_after_downsampled, 2), original_sampling_rate, downsample_factor) + signal_length + stim_duration;

    % Compute means and confidence intervals for plotting
    [mean_tinnitus_before, ci_tinnitus_before] = mean_ci(tinnitus_firing_before_downsampled);
    [mean_tinnitus_after, ci_tinnitus_after] = mean_ci(tinnitus_firing_after_downsampled);
    [mean_control_before, ci_control_before] = mean_ci(control_firing_before_downsampled);
    [mean_control_after, ci_control_after] = mean_ci(control_firing_after_downsampled);

    % Plot the data
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
end
