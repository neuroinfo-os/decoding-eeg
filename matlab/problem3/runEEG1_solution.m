% -------------------------------------------------------------------------
% block 1, preprocessing, MRA, plots
% -------------------------------------------------------------------------

clear
close all

% sampling frequency is 5 kHz
f_s = 5000;

% load signal, get dimensions
load('block1')
[nChans, nPts, nSweeps] = size(EEG.data);

% plot the first 3 epochs of all channels, then pause
data3 = reshape(EEG.data(:, :, 1:3), nChans, 3*nPts);
mean3 = mean(data3, 2);
sd3 = mean(std(data3, [], 2));
data3 = (data3-repmat(mean3, 1, length(data3)))/(3*sd3) + ...
    repmat((1:nChans)', 1, length(data3));
figure('units', 'normalized', 'outerposition', [0 0 1 1])
t = (1:length(data3))/f_s;
plot(t, data3)
hold on
line(nPts/f_s*[1 2; 1 2], (nChans+1)*[0 0; 1 1], 'color', [0 0 0 0.5], ...
    'linewidth', 2)
set(gca, 'ytick', 1:nChans, 'yticklabel', 1:nChans, ...
    'xlim', [t(1) t(end)],  'ylim', [0 nChans+1])
xlabel('t [s]')
ylabel('channels')
title('all channels, first 3 epochs')
pause

% load filter. use fdatool to build filter first
load('filterLP_1000_1200.mat')

for iChan=1:nChans
    
    % reshape channel data
    signal = squeeze(EEG.data(iChan, :, :));
    
    %% analyze
    
    % filter the signal. apply low-pass and 50 Hz notch filter, then
    % correct for baseline
    signal = filtfilt(filterLP.Numerator, 1, signal);
    signal = cleanAC(signal, 50, f_s);
    baseline = mean(signal((-49:50)+512, :));
    signal = signal - repmat(baseline, nPts, 1);
    
    % extract ERP as mean over sweeps
    ERP = mean(signal(513:1024, :), 2);
    
    % compute wavelet transform
    sWT = MRA_stationary_fast(signal, 'db4', f_s);
    
    % reconstruct the ERP from the MRA components
    WT2ERP = zeros(512, 7);
    for iScale=1:7
        WT2ERP(:, iScale) = ...
            mean(sum(sWT.scales(513:1024, :, 1:iScale), 3), 2);
    end
    
    %% plot
    
    t = (1:512)*1000/f_s;
    
    % MRA components for epoch 1
    figure('Name', ['WT scales, epoch 1, Ch ' num2str(iChan)], ...
        'units', 'normalized', 'outerposition', [0 0 0.5 1])
    for iScale=1:7
        subplot(4, 2, iScale)
        plot(t, squeeze(sWT.scales(513:1024, 1, iScale)))
        set(gca, 'xlim', [t(1) t(end)])
        title(['scale ' num2str(iScale)])
        xlabel('t [ms]')
    end
    subplot(4, 2, 8)
    plot(t, signal(513:1024, 1))
    set(gca, 'xlim', [t(1) t(end)])
    title('original sweep')
    xlabel('t [ms]')
    
    % ERP reconstruction
    figure('Name', ['reconstructed ERP, Ch ' num2str(iChan)], ...
        'units', 'normalized', 'outerposition', [0.5 0 0.5 1])
    for iScale=1:7
        subplot(4, 2, iScale)
        plot(t, WT2ERP(:, iScale))
        set(gca, 'xlim', [t(1) t(end)])
        title([num2str(iScale) ' scales'])
        xlabel('t [ms]')
    end
    subplot(4, 2, 8)
    plot(t, ERP)
    set(gca, 'xlim', [t(1) t(end)])
    title('original ERP')
    xlabel('t [ms]')
    
    % halt (press any key to continue)
    if iChan < nChans
        pause
    end
    
    close 2 3
    
end
