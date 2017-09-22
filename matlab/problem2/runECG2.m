% -------------------------------------------------------------------------
% real data, 8 blocks, more processing, feature plotting
% -------------------------------------------------------------------------

clear
close all

% sampling frequency is 512 Hz
srate = 512;

% load filters
load('filterHP_0.5_1.5.mat')
load('filterLP_3_10.mat')

% prepare figures
f1 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
f2 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
f3 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
f4 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);

% phase locking pack size
packSize = 11;

% analyze blocks 1 to 8
for B=1:8
    
    %% analyze ------------------------------------------------------------
    
    % load data, get signal from channel 3
    load(['block_' num2str(B)])
    signal = block_data(:, 3);

    % create high-pass and band-pass filtered signals by combining filters
    signalHP = ...
    signalBP = ...

    % extract QRS complex positions, using the high-pass filtered signal
    [H2, HDR, s] = qrsdetect(signalHP, srate, 1);
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
    waves = nan(length(timeWindow), length(peakPos)-2);
    phases = nan(length(timeWindow), length(peakPos)-2);
    for iEpoch=2:(length(peakPos)-1)
        wavesTmp = singalHP(...);
        waves(:, iEpoch-1) = wavesTmp - mean(wavesTmp);
        phasesTmp = unwrap(...);
        phases(:, iEpoch-1) = phasesTmp - ...
    end
    
    % compute phase locking values over epochs. for each epoch of the
    % high-pass filtered signal's unwrapped phase, compute the PLV across
    % its symmetric neighborhood of epochs for each time point. ignore
    % early and late epochs without symmetric neighborhood
    margin = floor(packSize/2);
    plv = nan(length(timeWindow), size(phases, 2));
    for iEpoch=margin+1:size(plv, 2)-margin
        thisPack = ...
        plv(:, iEpoch) = ...
    end
    
    %% plot (nothing to change here) --------------------------------------
    
    blk = [' block ', num2str(B)];
    t = (1:length(signal))/srate;
    
    % show first 4 seconds of signal and phase
    t0 = 1;
    t1 = 4*srate;
    
    % signal detailed
    figure(f1)
    subplot(4, 2, B)
    plot(t(t0:t1), signalHP(t0:t1), 'r');
    hold on
    plot(t(t0:t1), signalBP(t0:t1), 'g');
    set(gca, 'xlim', [t(t0) t(t1)], 'ylim', [-300 300]);
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
    set(gca, 'xlim', [t(1) t(length(timeWindow))], 'ylim', [-300 300]);
    title(['QRS', blk])
    ylabel('\muV')
    xlabel('time [s]')
    
    % phase locking values
    figure(f4)
    subplot(4, 2, B)
    imagesc(t(1:length(timeWindow)), margin+1:size(plv, 2)-margin, ...
        plv(:, margin+1:size(plv, 2)-margin)', [0 1])
    colormap jet
    ylabel('epoch')
    xlabel('time [s]')
    title(['phase locking', blk])
    
end

% add colorbar to PLV figure
axes, axis off
colorbar('position', [0.94 0.4 0.02 0.2])
