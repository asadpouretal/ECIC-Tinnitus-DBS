function plot_average_firing_rate(parent_folder)
    % Define the sampling rate for the firing rate signal
    sampling_rate = 5000; % Hz

    % Define the paths to the before and after stimulation folders
    before_folder = fullfile(parent_folder, 'Before stimulation');
    after_folder = fullfile(parent_folder, 'After stimulation');
    
    % Get list of rats before and after stimulation
    rats_before = dir(fullfile(before_folder, 'Rat*'));
    rats_after = dir(fullfile(after_folder, 'Rat*'));

    % Initialize arrays to collect firing rate data
    firing_rates_before = [];
    firing_rates_after = [];

    % Collect firing rates before stimulation
    for i = 1:length(rats_before)
        load(fullfile(rats_before(i).folder, rats_before(i).name, 'Results', 'results.mat'), 'results');
        if length(results.downsampled_firing_rate_signal) ~= results.params.down_sampled_FR_frequency* 300
            continue
        else
        firing_rates_before = [firing_rates_before; results.downsampled_firing_rate_signal];
        end
    end

    % Collect firing rates after stimulation
    for i = 1:length(rats_after)
        load(fullfile(rats_after(i).folder, rats_after(i).name, 'Results', 'results.mat'), 'results');
        if length(results.downsampled_firing_rate_signal) ~= results.params.down_sampled_FR_frequency* 300
            continue
        else
        firing_rates_after = [firing_rates_after; results.downsampled_firing_rate_signal];
        end
    end

    % Calculate mean and 95% confidence intervals
    mean_before = mean(firing_rates_before, 1);
    mean_after = mean(firing_rates_after, 1);

    ci_before = 1.96 * std(firing_rates_before, 0, 1) / sqrt(size(firing_rates_before, 1));
    ci_after = 1.96 * std(firing_rates_after, 0, 1) / sqrt(size(firing_rates_after, 1));

    % Create time vector
    time_vector = (0:(size(firing_rates_before, 2)-1)) / sampling_rate;

    % Plot the average firing rate with confidence intervals
    figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.4, 0.5]);
    hold on;
    shadedErrorBar(time_vector, mean_before, ci_before, {'-b', 'LineWidth', 2}, {});
    shadedErrorBar(time_vector, mean_after, ci_after, {'-r', 'LineWidth', 2}, {});
    plot(time_vector, mean_before, '-b', 'LineWidth', 2, 'DisplayName', 'Pre stim.');
    plot(time_vector, mean_after, '-r', 'LineWidth', 2, 'DisplayName', 'Post stim.');
    % title('Average Firing Rate Before and After Stimulation');
    xlabel('Time (s)', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Firing rate (Hz)', 'FontSize', 14, 'FontWeight', 'bold');
    legend('show');
    hold off;
    set(gca, 'FontSize', 12, 'FontWeight', 'bold', 'TickDir', 'out', 'Box', 'off');
end
