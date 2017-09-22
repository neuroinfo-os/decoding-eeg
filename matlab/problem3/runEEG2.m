% -------------------------------------------------------------------------
% 3 blocks, 1 channel, preprocessing, MRA, amplitude & phase & PLV, plots
% -------------------------------------------------------------------------

clear
close all

% sampling frequency is 5 kHz
srate = 5000;

% load filters
load('filterHP_0.1_10.mat')
load('filterLP_1000_1200.mat')

% phase locking pack size
packSize = 11;

% specify 1 channel to use, based on your previous analyses
useChan = ...

for B=1:3
    
    %% analyze ------------------------------------------------------------
    
    % load and reshape data, get dimensions
    load(['block', num2str(B)])
    signal = squeeze(EEG.data(useChan, :, :));
    [nPts, nEpochs] = size(signal);
    
    % filter the signal. apply high-pass and low-pass filters and a 50 Hz
    % notch filter, then correct for baseline (subtract from each epoch its
    % mean signal over 100 pt around the 2nd sweep onset)
    signal = filtfilt(filterHP, 1, signal);
    signal = filtfilt(filterLP, 1, signal);
    signal = cleanAC(signal, 50, srate);
    baseline = ...
    signal = signal - ...
    
    % compute wavelet transform
    sWT = MRA_stationary_fast(signal, 'db4', srate);
    
    % compute instantaneous phase and amplitude for all epochs and scales
    % (no need to leave out the first and last trials here, since the data
    % are already epoched). subtract from each phase epoch the value right
    % before the 2nd sweep's onset
    Amp = nan(nPts, nEpochs, 7);
    Phase = nan(nPts, nEpochs, 7);
    for iScale=1:7
        thisScale = sWT.scales(:, :, iScale);
        Amp(:, :, iScale) = ...
        phaseTmp = unwrap(...);
        Phase(:, :, iScale) = phaseTmp - ...
    end
    
    % compute phase locking values across epochs for each scale and time
    % point
    margin = floor(packSize/2);
    PLV = nan(nPts, nEpochs, 7);
    for iEpoch=margin+1:nEpochs-margin
        thisPack = ...
        PLV(:, iEpoch, :) = ...
    end
    
    %% plot (nothing to change here) --------------------------------------
    
    t = (1:512)*1000/srate;
    ylimsAmp = [20 20 10 10 10 5 5];
    ylimsPha = [10 20 50 100 200 300 600];
    
    % features per block and scale
    figure('name', ['block ' num2str(B)], ...
        'units', 'normalized', 'outerposition', [0 0 1 1]);
    for iScale=1:7
        % Amp (examples and mean)
        subplot(7, 3, (iScale-1)*3+1)
        plot(t, Amp(513:1024, 20:20:end, iScale), 'color', [0.3 0.3 0.3])
        hold on
        plot(t, mean(Amp(513:1024, :, iScale), 2), '-r', 'linewidth', 3)
        set(gca, 'xlim', [t(1) t(end)], 'ylim', [0 ylimsAmp(iScale)])
        if iScale==1
            title('Amp')
        elseif iScale==7
            xlabel('time [ms]')
        end
        text('units', 'normalized', 'position', [-0.3 0.4], ...
            'string', [num2str(round(sWT.freqs(iScale)/2)) ' Hz']);
        % Phase (examples and mean)
        subplot(7, 3, (iScale-1)*3+2)
        plot(t, Phase(513:1024, 20:20:end, iScale), 'color', [0.3 0.3 0.3])
        hold on
        plot(t, mean(Phase(513:1024, :, iScale), 2), '-b', 'linewidth', 3)
        set(gca, 'xlim', [t(1) t(end)], 'ylim', [0 ylimsPha(iScale)])
        if iScale==1
            title('Phase')
        elseif iScale==7
            xlabel('time [ms]')
        end
        % PLV (complete)
        subplot(7, 3, (iScale-1)*3+3)
        imagesc(t, margin+1:nEpochs-margin, ...
            PLV(513:1024, margin+1:nEpochs-margin, iScale)', [0 1])
        colormap jet
        if iScale==1
            title('PLV')
        elseif iScale==7
            xlabel('time [ms]')
        end
    end
    
end

% press key to zoom in
pause
set(findobj('type', 'axes'), 'xlim', [t(1) t(75)])
for iFig=1:3
    figure(iFig)
    for iPlot=1:7
        subplot(7, 3, 3*(iPlot-1)+2)
        set(gca, 'ylim', [0 ylimsPha(iPlot)/5])
    end
end
