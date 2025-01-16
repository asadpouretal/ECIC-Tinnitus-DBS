function spike_times_NEO = detect_spikes_NEO(data, multiplier)
    neo_signal = compute_NEO(data);
    threshold_NEO = mean(neo_signal) + multiplier * std(neo_signal);
    spike_times_NEO = find(neo_signal > threshold_NEO);
    for i = length(spike_times_NEO):-1:2
        if (spike_times_NEO(i) - spike_times_NEO(i-1)) == 1
            if neo_signal(spike_times_NEO(i)) > neo_signal(spike_times_NEO(i-1))
                spike_times_NEO(i-1) = [];
            else
                spike_times_NEO(i) = [];
            end
        end
    end
end
