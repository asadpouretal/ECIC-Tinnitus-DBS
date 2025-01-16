function [spike_times_MAD, spike_train, MAD_multiplier] = calculate_MAD(data, params, Fs)
    confirmed = false;
    MAD_multiplier = params.MAD_multiplier;
    while ~confirmed
        [spike_times_MAD, spike_train] = detect_spikes_MAD(data, params, Fs);

        % Visual Comparison
        fig = figure('WindowState','maximized');

        time = (0:length(data)-1) / Fs;  % Convert sample indices to time
        plot(time, data);
        hold on;
        plot(time(spike_times_MAD), data(spike_times_MAD), 'ro');
        xlabel('Time (s)');  % Label x-axis as time
        title('Spikes detected using MAD method');

        choice = menu('Is the spike detection acceptable?', 'Yes', 'No');
        if choice == 1
            confirmed = true;
        else
            prompt = {'Enter new MAD multiplier (higher to increase the threshold):'};
            dlgtitle = 'Input';
            dims = [1 35];
            definput = {num2str(MAD_multiplier)};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            MAD_multiplier = str2double(answer{1});
            params.MAD_multiplier = MAD_multiplier;
            close(fig);
        end
    end
end
