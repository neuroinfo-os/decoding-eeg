% -------------------------------------------------------------------------
% real data, 8 blocks, more processing, feature plotting
% -------------------------------------------------------------------------

clear
close all

% sampling frequency is 512 Hz
f_s = 512;

% load filters
load('filterHP_0.5_1.5.mat')
load('filterLP_3_10.mat')

% prepare figures for plots
f1 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
f2 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
f3 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
f4 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);

% phase locking pack size
packSize = 25;

% analyze blocks 1 to 8
for B=1:8
    
    %% analyze
    
    % load data, get signal from channel 3
    load(['block_' num2str(B)])
    signal = block_data(:, 3);
    
    % create high-pass and band-pass filtered signals by combining filters
    signalHP = ...
    signalBP = ...
    
    % extract QRS complex positions, using the high-pass filtered signal
    [H2, HDR, s] = qrsdetect(signalHP, f_s, 1);
    peakPos = H2.EVENT.POS;
    
    % compute phases for the high-pass and band-pass filtered signals
    phaseHP = ...
    phaseBP = ...
    
    % isolate QRS waves and phases of the high-pass filtered signal. define
    % a time window around each QRS peak, cut out the single epochs, and
    % stack them into matrices. align each signal epoch to its mean and
    % each phase epoch to its value at the time of the QRS peak. leave out
    % the first and last epoch to avoid indexing errors
    timeWindow = ...
    waves = zeros(length(timeWindow), length(peakPos)-2);
    phases = zeros(length(timeWindow), length(peakPos)-2);
    for iEpoch=2:(length(peakPos)-1)
        ...
        waves(:, iEpoch-1) = ...
        tmp = unwrap(...);
        phases(:, iEpoch-1) = tmp - ...
    end
    
    % compute phase locking values over time. for each pack of epochs of
    % the high-pass filtered signal's unwrapped phase, compute the average
    % phase angle similarity per time point over epochs, to obtain one PLV
    % time series per pack
    nPacks = floor(size(phases, 2)/packSize);
    plv = zeros(length(timeWindow), nPacks);
    for iPack=1:nPacks
        thisPack = ...
        plv(:, iPack) = ...
    end
    
    %% plot (nothing to change here)
    
    blk = [' block ', num2str(B)];
    t = (1:length(signal))/f_s;
    
    % show first 4 seconds of signal and phase
    t0 = 1;
    t1 = 4*f_s;
    
    % signal detailed
    figure(f1)
    subplot(4, 2, B)
    plot(t(t0:t1), signalHP(t0:t1), 'r');
    hold on
    plot(t(t0:t1), signalBP(t0:t1), 'g');
    set(gca, 'xlim', [t(t0) t(t1)]);
    title(['detailed signal', blk])
    ylabel('\muV')
    xlabel('time [s]')
    if B==1
        legend('high-pass', 'band-pass');
    end
    
    % phase detailed
    figure(f2)
    subplot(4, 2, B)
    plot(t(t0:t1), phaseHP(t0:t1), 'r')
    hold on
    plot(t(t0:t1), phaseBP(t0:t1), 'g')
    set(gca, 'xlim', [t(t0) t(t1)], ...
        'ytick', [-pi 0 pi], ...
        'yticklabel', {'-\pi', '0', '\pi'});
    title(['detailed phase', blk])
    ylabel('\phi')
    xlabel('time [s]')
    if B==1
        legend('high-pass', 'band-pass');
    end
    
    % QRS waves
    figure(f3)
    subplot(4, 2, B)
    plot(t(1:length(timeWindow)), waves)
    hold on
    plot(t(1:length(timeWindow)), mean(waves, 2), 'linewidth', 2, ...
        'color', [0.3 0.3 0.3])
    set(gca, 'xlim', [t(1) t(length(timeWindow))]);
    title(['QRS', blk])
    ylabel('\muV')
    xlabel('time [s]')
    
    % phase locking values
    figure(f4)
    subplot(4, 2, B)
    imagesc(t(1:length(timeWindow)), 1:nPacks, plv', [0 1])
    colormap jet
    ylabel('pack no.')
    xlabel('time [s]')
    title(['phase locking', blk])
    
end

% add colorbar to PLV figure
axes, axis off
colorbar('position', [0.94 0.4 0.02 0.2])
