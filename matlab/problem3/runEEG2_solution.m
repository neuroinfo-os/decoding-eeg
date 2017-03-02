% -------------------------------------------------------------------------
% 3 blocks, 1 channel, preprocessing, MRA, power & phase & PLV, plots
% -------------------------------------------------------------------------

clear
close all

% sampling frequency is 5 kHz
f_s = 5000;

% load filter. use fdatool to build filter first
load('filterLP_1000_1200.mat')

% phase locking pack size
packSize = 20;

% specify 1 channel to use
useChan = 7;

for B=1:3
    
    %% analyze
    
    % load and reshape data, get dimensions
    load(['block', num2str(B)])
    signal = squeeze(EEG.data(useChan, :, :));
    [nPts, nSweeps] = size(signal);
    
    % filter the signal. apply low-pass and 50 Hz notch filter, then
    % correct for baseline
    signal = filtfilt(filterLP.Numerator, 1, signal);
    signal = cleanAC(signal, 50, f_s);
    baseline = mean(signal((-49:50)+512, :));
    signal = signal - repmat(baseline, nPts, 1);
    
    % compute wavelet transform
    sWT = MRA_stationary_fast(signal, 'db4', f_s);
    
    % compute instantaneous phase and power for all sweeps and scales
    Power = zeros(nPts, nSweeps, 7);
    Phase = zeros(nPts, nSweeps, 7);
    for iScale=1:7
        sTmp = sWT.scales(:, :, iScale);
        Power(:, :, iScale) = abs(hilbert(sTmp));
        phaseTmp = unwrap(angle(hilbert(sTmp)));
        Phase(:, :, iScale) = phaseTmp - repmat(phaseTmp(512, :), nPts, 1);
    end
    
    % compute phase locking values
    nPacks = floor(nSweeps/packSize);
    PLV = zeros(nPts, nPacks, 7);
    for iPack=1:nPacks
        thisPack = (iPack-1)*packSize + (1:packSize);
        PLV(:, iPack, :) = abs(mean(exp(1i*Phase(:, thisPack, :)), 2));
    end
    
    %% plot
    
    t = (1:512)*1000/f_s;
    
    % features per block and scale
    figure('name', ['block ' num2str(B)], ...
        'units', 'normalized', 'outerposition', [0 0 1 1]);
    for iScale=1:7
        % Power (examples and mean)
        subplot(7, 3, (iScale-1)*3+1)
        plot(t, Power(513:1024, 20:20:end, iScale))
        hold on
        plot(t, mean(Power(513:1024, :, iScale), 2), 'linewidth', 3, ...
            'color', [0.3 0.3 0.3])
        set(gca, 'xlim', [t(1) t(end)])
        if iScale==1
            title('Power')
        elseif iScale==7
            xlabel('time [ms]')
        end
        text('units', 'normalized', 'position', [-0.3 0.4], ...
            'string', [num2str(round(sWT.freqs(iScale)/2)) ' Hz']);
        % Phase (examples and mean)
        subplot(7, 3, (iScale-1)*3+2)
        plot(t, Phase(513:1024, 20:20:end, iScale))
        hold on
        plot(t, mean(Phase(513:1024, :, iScale), 2), 'linewidth', 3, ...
            'color', [0.3 0.3 0.3])
        set(gca, 'xlim', [t(1) t(end)])
        if iScale==1
            title('Phase')
        elseif iScale==7
            xlabel('time [ms]')
        end
        % PLV (complete)
        subplot(7, 3, (iScale-1)*3+3)
        imagesc(t, 1:nPacks, PLV(513:1024, :, iScale)', [0 1])
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
