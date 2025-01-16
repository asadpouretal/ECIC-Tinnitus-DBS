function plot_average_burst_rate(parent_folder)
    % Define the sampling rate for the burst rate signal
    sampling_rate = 1000; % Hz

    % Define the paths to the before and after stimulation folders
    before_folder = fullfile(parent_folder, 'Before stimulation');
    after_folder = fullfile(parent_folder, 'After stimulation');
    
    % Get list of rats before and after stimulation
    rats_before = dir(fullfile(before_folder, 'Rat*'));
    rats_after = dir(fullfile(after_folder, 'Rat*'));

    % Initialize arrays to collect burst rate data
    burst_rates_before = [];
    burst_rates_after = [];

    % Collect burst rates before stimulation
    for i = 1:length(rats_before)
        load(fullfile(rats_before(i).folder, rats_before(i).name, 'Results', 'results.mat'), 'results');
        burst_rates_before = [burst_rates_before; results.burst_firing_rate];
    end

    % Collect burst rates after stimulation
    for i = 1:length(rats_after)
        load(fullfile(rats_after(i).folder, rats_after(i).name, 'Results', 'results.mat'), 'results');
        burst_rates_after = [burst_rates_after; results.burst_firing_rate];
    end

    % Calculate mean and 95% confidence intervals
    mean_before = mean(burst_rates_before, 1);
    mean_after = mean(burst_rates_after, 1);

    ci_before = 1.96 * std(burst_rates_before, 0, 1) / sqrt(size(burst_rates_before, 1));
    ci_after = 1.96 * std(burst_rates_after, 0, 1) / sqrt(size(burst_rates_after, 1));

    % Create time vector
    time_vector = (0:(size(burst_rates_before, 2)-1)) / sampling_rate;

    % Plot the average burst rate with confidence intervals
    figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.4, 0.5]);
    hold on;
    shadedErrorBar(time_vector, mean_before, ci_before, {'-b', 'LineWidth', 2}, {'FaceAlpha', 0.1});
    shadedErrorBar(time_vector, mean_after, ci_after, {'-r', 'LineWidth', 2}, {'FaceAlpha', 0.1});
    plot(time_vector, mean_before, '-b', 'LineWidth', 2, 'DisplayName', 'Before Stimulation');
    plot(time_vector, mean_after, '-r', 'LineWidth', 2, 'DisplayName', 'After Stimulation');
    % title('Average Burst Rate Before and After Stimulation', 'FontSize', 16, 'FontWeight', 'bold');
    xlabel('Time (s)', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Burst Rate (bursts per minute)', 'FontSize', 14, 'FontWeight', 'bold');    
    legend('show');
    hold off;
    % Set custom axes properties
    set(gca, 'FontSize', 12, 'FontWeight', 'bold', 'TickDir', 'out', 'Box', 'off', ...
             'LineWidth', 1.5, 'TickLength', [0.02, 0.02]);
end
