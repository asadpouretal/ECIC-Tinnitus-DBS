function neo_signal = compute_NEO(data)
    % Compute the Non-linear Energy Operator (NEO) for a given signal
    neo_signal = zeros(size(data));
    for n = 2:length(data)-1
        neo_signal(n) = data(n)^2 - data(n-1) * data(n+1);
    end
end
