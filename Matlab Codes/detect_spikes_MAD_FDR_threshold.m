function spike_times_MAD = detect_spikes_MAD_FDR_threshold(data, q)
    threshold = compute_FDR_threshold(data, q);
    spike_times_MAD = find(data > threshold);
    for i = length(spike_times_MAD):-1:2
        if (spike_times_MAD(i) - spike_times_MAD(i-1)) == 1
            if data(spike_times_MAD(i)) > data(spike_times_MAD(i-1))
                spike_times_MAD(i-1) = [];
            else
                spike_times_MAD(i) = [];
            end
        end
    end
end
