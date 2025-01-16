function spike_times_MAD = compare_MAD_NEO(data, MAD_multiplier, neo_multiplier)
    [spike_times_MAD, spike_train] = detect_spikes_MAD(data, MAD_multiplier);
    spike_times_NEO = detect_spikes_NEO(data, neo_multiplier);

    % Visual Comparison
    figure;

    subplot(2,1,1);
    plot(data);
    hold on;
    plot(spike_times_MAD, data(spike_times_MAD), 'ro');
    title('FDR-adjusted MAD method');

    subplot(2,1,2);
    plot(data);
    hold on;
    plot(spike_times_NEO, data(spike_times_NEO), 'ro');
    title('NEO method');
end
