function compare_isi_pdf(parent_folder)
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

    % Estimate PDFs using kernel smoothing
    [pdf_before, xi_before] = ksdensity(ISIs_before);
    [pdf_after, xi_after] = ksdensity(ISIs_after);

    % Plot the PDFs on the same plot
    figure;
    hold on;
    plot(xi_before, pdf_before, 'b', 'LineWidth', 2);
    plot(xi_after, pdf_after, 'r', 'LineWidth', 2);
    title('ISI PDF Before and After Stimulation');
    xlabel('Inter-Spike Interval (ms)');
    ylabel('Probability Density');
    legend('Before Stimulation', 'After Stimulation');
    hold off;
    xlim([0 5000])
    % Set custom axes properties
    set(gca, 'FontSize', 12, 'FontWeight', 'bold', 'TickDir', 'out', 'Box', 'off', ...
             'LineWidth', 1.5, 'TickLength', [0.02, 0.02]);
end
