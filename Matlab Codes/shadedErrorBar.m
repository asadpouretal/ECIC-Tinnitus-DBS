function shadedErrorBar(x, y, errBar, varargin)
    % Check if x is empty, if so, create a default x
    if isempty(x)
        x = 1:length(y);
    end

    % Default plot properties
    plotProps = {'-b', 'LineWidth', 2};
    patchProps = {'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off'};

    % Check for additional arguments and override the defaults
    if nargin > 3
        plotProps = varargin{1};
    end
    if nargin > 4
        patchProps = [patchProps, varargin{2}];
    end

    % Calculate the upper and lower bounds of the shaded area
    yUpper = y + errBar;
    yLower = y - errBar;

    % Plot the shaded area
    fill([x, fliplr(x)], [yUpper, fliplr(yLower)], plotProps{1}, patchProps{:});
    hold on;

    % % Plot the main line
    plot(x, y, plotProps{:});
end
