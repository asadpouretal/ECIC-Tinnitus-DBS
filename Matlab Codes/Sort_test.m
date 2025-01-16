Spikes = results.spike_waveforms;
Sample_data=size(Spikes,1);
sampling_rate = 50000;

Dim_sub=3; %dim of feature subspace
numCluster0=4; %initial cluster num
flagMerge=1; %1:merge 0: non-merge


[Idx_sort,Idx_center]=ldadp_fuc(Spikes,Sample_data,Dim_sub,numCluster0,flagMerge);

filtered_data = zeros(1, 300*sampling_rate);
spike_times = results.spike_times_MAD;
[cluster_spikes, cluster_spike_times, cluster_spike_trains, cluster_firing_rates] = plot_cluster_waveforms(Spikes, spike_times, Idx_sort, filtered_data, sampling_rate, params);