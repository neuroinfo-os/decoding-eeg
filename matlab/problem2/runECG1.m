% -------------------------------------------------------------------------
% example ECG, some processing, exhaustive plotting
% -------------------------------------------------------------------------

clear
close all

%% analyze signal ---------------------------------------------------------

% sampling frequency is 512 Hz
srate = 512;
T = 1/srate;

% load data, get signal from channel 3
load('ECG_signal_3')
signal = ECG_signal(:, 3);

% load filters. use fdatool to build filters first
load('filterHP_0.5_1.5.mat')
load('filterLP_3_10.mat')

% create high-pass and band-pass filtered signals by combining filters. try
% to avoid phase shifting
signalHP = ...
signalBP = ...

% extract QRS complex positions, using the high-pass filtered signal
[H2, HDR, s] = qrsdetect(signalHP, srate, 1);
peakPos = H2.EVENT.POS;

% get power spectra of all 3 filtered signals
[spectrumFull, f_axis] = Powerspektrum(signal, T, 2048);
[spectrumHP, ~] = Powerspektrum(signalHP, T, 2048);
[spectrumBP, ~] = Powerspektrum(signalBP, T, 2048);

% compute analytical signal and phase for all 3 filtered signals
anaSignal = ...
anaSignalHP = ...
anaSignalBP = ...
phase = ...
phaseHP = ...
phaseBP = ...

% isolate QRS waves of the high-pass filtered signal. define a time window
% around each QRS peak, cut out the single epochs, align each epoch to its
% mean, and stack them into a matrix. leave out the first and last epoch to
% avoid indexing errors
timeWindow = ...
waves = nan(length(timeWindow), length(peakPos)-2);
for iEpoch=2:(length(peakPos)-1)
    wavesTmp = signalHP(...);
    waves(:, iEpoch-1) = wavesTmp - mean(wavesTmp);
end

%% plot (edit the last part!) ---------------------------------------------

t = (1:length(signal))/srate;

% frequency spectra
figure('units', 'normalized', 'outerposition', [0 0 1 1])
subplot(211)
loglog(f_axis, spectrumFull, 'b')
hold on
loglog(f_axis, spectrumHP, 'r')
loglog(f_axis, spectrumBP, 'g')
set(gca, 'xlim', [0 f_axis(end)])
title('frequency spectra')
legend({'original', 'high-pass', 'band-pass'}, 'location', 'northeast')
ylabel('Power')
xlabel('f [Hz]')

% auto-correlation
subplot(212)
hold off
[a, b] = xcorr(signal, 'unbiased');
plot(b/srate, a, 'b')
hold on
[a, b] = xcorr(signalHP, 'unbiased');
plot(b/srate, a, 'r')
[a, b] = xcorr(signalBP, 'unbiased');
plot(b/srate, a, 'g')
set(gca, 'xlim', [-2 2])
title('auto-correlation')
legend({'original', 'high-pass', 'band-pass'}, 'location', 'northeast')
xlabel('\Deltat [s]')

% signal and phase portrait
figure('units', 'normalized', 'outerposition', [0 0 1 1])
subplot(321)
plot(t, signal);
set(gca, 'xlim', [t(1) t(end)])
title('signal, original')
ylabel('\muV')
xlabel('time [s]')
subplot(322)
plot(real(anaSignal), imag(anaSignal))
title('phase, original')
ylabel('imag')
xlabel('real')

subplot(323)
plot(t, signalHP);
set(gca, 'xlim', [t(1) t(end)])
title('signal, high-pass')
ylabel('\muV')
xlabel('time [s]')
subplot(324)
plot(real(anaSignalHP), imag(anaSignalHP))
title('phase, high-pass')
ylabel('imag')
xlabel('real')

subplot(325)
plot(t, signalBP);
title('signal, band-pass')
set(gca, 'xlim', [t(1) t(end)])
ylabel('\muV')
xlabel('time [s]')
subplot(326)
plot(real(anaSignalBP), imag(anaSignalBP))
title('phase, band-pass')
ylabel('imag')
xlabel('real')

% signal and phase, detail
figure('units', 'normalized', 'outerposition', [0 0 1 1])
subplot(211)
plot(t, signal, 'b')
hold on
plot(t, signalHP, 'r')
plot(t, signalBP, 'g')
set(gca, 'xlim', [20 25])
title('detailed signal')
ylabel('\muV')
xlabel('time [s]')
legend('original', 'high-pass', 'band-pass')
subplot(212)
plot(t, phase, 'b')
hold on
plot(t, phaseHP, 'r')
plot(t, phaseBP, 'g')
set(gca, 'xlim', [20 25], ...
    'ytick', [-pi 0 pi], 'yticklabel', {'-\pi', '0', '\pi'})
title('detailed phase')
ylabel('\phi')
xlabel('time [s]')
legend('original', 'high-pass', 'band-pass')

% QRS peaks
figure('units', 'normalized', 'outerposition', [0 0 1 1])
subplot(211)
plot(t, signalHP)
hold on 
plot(t(peakPos), 0*peakPos, 'rx', 'LineWidth', 2) 
set(gca, 'xlim', [t(1) t(end)])
title('QRS complexes')
ylabel('\muV')
xlabel('time [s]')

% QRS waves
subplot(212)
plot(t(1:length(timeWindow)), waves)
hold on
plot(t(1:length(timeWindow)), mean(waves, 2), 'LineWidth', 2, ...
    'color', [0.3 0.3 0.3])
set(gca, 'xlim', [t(1) t(length(timeWindow))])
title('detailed QRS, single and average')
ylabel('\muV')
xlabel('time [s]')

% isolate and plot QRS waves for all 8 channels
f1 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
f2 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
cmap = jet(8);
for iChan=1:8
    figure(f1)
    subplot(4, 2, iChan)
    % compute waves as above, reusing peakPos and timeWindow
    signal = ECG_signal(:, iChan);
    signalHP = ... % your code goes here
    waves = nan(length(timeWindow), length(peakPos)-2);
    for iEpoch=2:(length(peakPos)-1)
        wavesTmp = signalHP(...); % and here
        waves(:, iEpoch-1) = wavesTmp - mean(wavesTmp);
    end
    plot(t(1:length(timeWindow)), waves)
    hold on
    plot(t(1:length(timeWindow)), mean(waves, 2), 'LineWidth', 2, ...
        'color', [0.3 0.3 0.3])
    set(gca, 'ylim', [-2000 1000])
    title(['QRS ch', num2str(iChan)])
    ylabel('\muV')
    xlabel('time [s]')
    figure(f2)
    plot(t(1:length(timeWindow)), mean(waves, 2), 'LineWidth', 2, ...
        'color', cmap(iChan, :))
    hold on
    title('QRS all channels')
    ylabel('\muV')
    xlabel('time [s]')
end
legend({'ch 1', 'ch 2', 'ch 3', 'ch 4', 'ch 5', 'ch 6', 'ch 7', 'ch 8'}, ...
    'location', 'south')
