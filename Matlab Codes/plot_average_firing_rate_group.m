function plot_average_firing_rate_group(parent_folder)
    % Define the sampling rate for the firing rate signal and downsampling factor
    original_sampling_rate = 5000; % Hz
    downsample_factor = 50;  % Reduce by a factor of 50 (from 5000 Hz to 100 Hz)
    stim_duration = 60; % seconds (gray area)
    signal_length = 300; % seconds
    
    % Define paths to the Before and After stimulation subfolders for both groups
    tinnitus_before_folder = fullfile(parent_folder, 'Tinnitus', 'Before stimulation');
    tinnitus_after_folder = fullfile(parent_folder, 'Tinnitus', 'After stimulation');
    control_before_folder = fullfile(parent_folder, 'Control', 'Before stimulation');
    control_after_folder = fullfile(parent_folder, 'Control', 'After stimulation');

    % Load the firing rates for both groups
    tinnitus_before_files = dir(fullfile(tinnitus_before_folder, 'Rat*', 'Results', 'results.mat'));
    tinnitus_after_files = dir(fullfile(tinnitus_after_folder, 'Rat*', 'Results', 'results.mat'));
    control_before_files = dir(fullfile(control_before_folder, 'Rat*', 'Results', 'results.mat'));
    control_after_files = dir(fullfile(control_after_folder, 'Rat*', 'Results', 'results.mat'));

    % Initialize arrays for firing rates
    tinnitus_firing_before = [];
    tinnitus_firing_after = [];
    control_firing_before = [];
    control_firing_after = [];

    % Load tinnitus group data (before and after stimulation)
    for i = 1:length(tinnitus_before_files)
        load(fullfile(tinnitus_before_files(i).folder, 'results.mat'), 'results');
        if length(results.downsampled_firing_rate_signal) == results.params.down_sampled_FR_frequency * signal_length
            tinnitus_firing_before = [tinnitus_firing_before; results.downsampled_firing_rate_signal];
        end
    end
    for i = 1:length(tinnitus_after_files)
        load(fullfile(tinnitus_after_files(i).folder, 'results.mat'), 'results');
        if length(results.downsampled_firing_rate_signal) == results.params.down_sampled_FR_frequency * signal_length
            tinnitus_firing_after = [tinnitus_firing_after; results.downsampled_firing_rate_signal];
        end
    end

    % Load control group data (before and after stimulation)
    for i = 1:length(control_before_files)
        load(fullfile(control_before_files(i).folder, 'results.mat'), 'results');
        if length(results.downsampled_firing_rate_signal) == results.params.down_sampled_FR_frequency * signal_length
            control_firing_before = [control_firing_before; results.downsampled_firing_rate_signal];
        end
    end
    for i = 1:length(control_after_files)
        load(fullfile(control_after_files(i).folder, 'results.mat'), 'results');
        if length(results.downsampled_firing_rate_signal) == results.params.down_sampled_FR_frequency * signal_length
            control_firing_after = [control_firing_after; results.downsampled_firing_rate_signal];
        end
    end

    % Downsample the firing rates
    tinnitus_firing_before_downsampled = tinnitus_firing_before(:, 1:downsample_factor:end);
    tinnitus_firing_after_downsampled = tinnitus_firing_after(:, 1:downsample_factor:end);
    control_firing_before_downsampled = control_firing_before(:, 1:downsample_factor:end);
    control_firing_after_downsampled = control_firing_after(:, 1:downsample_factor:end);

    % Create time vectors for downsampled data
    time_vector_before_downsampled = (0:size(tinnitus_firing_before_downsampled, 2)-1) * (downsample_factor / original_sampling_rate);
    time_vector_after_downsampled = (0:size(tinnitus_firing_after_downsampled, 2)-1) * (downsample_factor / original_sampling_rate);

    % Compute means and confidence intervals for downsampled data
    [mean_tinnitus_before, ci_tinnitus_before] = mean_ci(tinnitus_firing_before_downsampled);
    [mean_tinnitus_after, ci_tinnitus_after] = mean_ci(tinnitus_firing_after_downsampled);
    [mean_control_before, ci_control_before] = mean_ci(control_firing_before_downsampled);
    [mean_control_after, ci_control_after] = mean_ci(control_firing_after_downsampled);

    % Plotting
    figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
    hold on;

    % Plot before stimulation activity
    shadedErrorBar(time_vector_before_downsampled, mean_control_before, ci_control_before, {'-b', 'LineWidth', 2}, {});
    shadedErrorBar(time_vector_before_downsampled, mean_tinnitus_before, ci_tinnitus_before, {'-r', 'LineWidth', 2}, {});

    % Add stimulation area (gray block)
    fill([signal_length signal_length+ stim_duration signal_length+ stim_duration signal_length], [min(ylim), min(ylim), max(ylim), max(ylim)], [0.8, 0.8, 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'HandleVisibility', 'off');

    % Plot after stimulation activity
    shadedErrorBar(time_vector_after_downsampled + signal_length+stim_duration, mean_control_after, ci_control_after, {'-b', 'LineWidth', 2}, {});
    shadedErrorBar(time_vector_after_downsampled + signal_length+stim_duration, mean_tinnitus_after, ci_tinnitus_after, {'-r', 'LineWidth', 2}, {});

    % Significance testing (t-test) at each time point (on downsampled data)
    for t = 1:size(tinnitus_firing_before_downsampled, 2)
        [~, p] = ttest2(tinnitus_firing_before_downsampled(:, t), control_firing_before_downsampled(:, t));
        if p < 0.05
            plot(time_vector_before_downsampled(t), min(ylim) + 0.1 * abs(min(ylim)), 'k.', 'MarkerSize', 10);
        end
    end
    for t = 1:size(tinnitus_firing_after_downsampled, 2)
        [~, p] = ttest2(tinnitus_firing_after_downsampled(:, t), control_firing_after_downsampled(:, t));
        if p < 0.05
            plot(time_vector_after_downsampled(t) + signal_length + stim_duration, min(ylim) + 0.1 * abs(min(ylim)), 'k.', 'MarkerSize', 10);
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

    % Labels and legend
    xlabel('Time (s)', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Firing Rate (Hz)', 'FontSize', 14, 'FontWeight', 'bold');
    legend({'Control', 'Tinnitus'}, 'Location', 'northeast');
    set(gca, 'FontSize', 12, 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out');
    hold off;
    xlim([0 2*signal_length + stim_duration]);

    % Helper function to compute mean and confidence intervals
    function [mean_data, ci_data] = mean_ci(data)
        mean_data = mean(data, 1);
        ci_data = 1.96 * std(data, 0, 1) / sqrt(size(data, 1));
    end
end
