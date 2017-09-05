# -------------------------------------------------------------------------
# example ECG, some processing, exhaustive plotting
# -------------------------------------------------------------------------

from pylab import *
from scipy.io import loadmat
import scipy.signal as sig
from rpeakdetect import detect_beats


# ----- analyze signals ----- #

# sampling frequency is 512 Hz
f_s = 512.0
T = 1 / f_s

# load channels & convert to float values
ecg_channels = loadmat('../../data/ECG/ECG_signal_3')
ecg_channels = ecg_channels['ECG_signal'].T
ecg_channels = ecg_channels.astype('float64')

# get signal from channel 3, create time vector
ecg_signal = ecg_channels[2]
t = arange(len(ecg_signal)) / f_s

# load filters designed with pyfda
filterHP = load('highpass_filter.npz')
filterLP = load('lowpass_filter.npz')

# create high-pass and band-pass filtered signals by combining filters
b, a = filterHP['ba']
signalHP = sig.filtfilt(b, a, ecg_signal)
b, a = filterLP['ba']
signalBP = sig.filtfilt(b, a, signalHP)

# extract QRS complex positions, using the high-pass filtered signal
peakPos = detect_beats(ecg_signal, f_s)

# get power spectra
f_axis, spectrumFull = sig.periodogram(ecg_signal, T)
_, spectrumHP = sig.periodogram(signalHP, T)
_, spectrumBP = sig.periodogram(signalBP, T)

# compute analytical signal and phase
anaSignal = sig.hilbert(ecg_signal)
anaSignalHP = sig.hilbert(signalHP)
anaSignalBP = sig.hilbert(signalBP)
phase = angle(anaSignal)
phaseHP = angle(anaSignalHP)
phaseBP = angle(anaSignalBP)

# Isolate QRS waves of the high-pass filtered signal. Define a time window
# around each QRS peak, cut out the single epochs, align each epoch to its
# mean, and stack them into matri   ces. Leave out the first and last epoch to
# avoid indexing errors.
timeWindow = arange(round(-0.2 * f_s), round(0.6 * f_s))
windows = peakPos[1:-1].reshape(-1, 1) + timeWindow
waves = signalHP[windows]
waves -= mean(waves, axis=0)


# ----- plot ----- #

# frequency spectra
subplot(211)
loglog(f_axis, spectrumFull, color='b', label='original')
loglog(f_axis, spectrumHP, color='r', label='high-pass')
loglog(f_axis, spectrumBP, color='g', label='band-pass')
title('frequency spectra')
legend(loc='best')
xlabel('f [Hz]')
ylabel('Power')
ylim([10**-5, 10**11])
xlim([0, max(f_axis)])
grid()

# auto-correlation
subplot(212)
cc = correlate(ecg_signal, ecg_signal, mode='full')
plot(cc, color='b', label='origianl')
cc = correlate(signalHP, signalHP, mode='full')
plot(cc, color='r', label='high-pass')
cc = correlate(signalBP, signalBP, mode='full')
plot(cc, color='g', label='band-pass')
xlim([len(cc) / 2 - 1000, len(cc) / 2 + 1000])
title('auto-correlation')
legend()

# signal and phase portrait
figure()
subplot(321)
plot(t, ecg_signal)
title('original signal')
ylabel('mV')
xlabel('time [s]')
subplot(322)
plot(real(anaSignal), imag(anaSignal))
title('phase, original')
ylabel('imag')
xlabel('real')

subplot(323)
plot(t, signalHP)
title('high-pass filtered signal')
ylabel('mV')
xlabel('time [s]')
subplot(324)
plot(real(anaSignalHP), imag(anaSignalHP))
title('phase, high-pass')
ylabel('imag')
xlabel('real')

subplot(325)
plot(t, signalBP)
title('band-pass filtered signal')
ylabel('mV')
xlabel('time [s]')
subplot(326)
plot(real(anaSignalBP), imag(anaSignalBP))
title('phase, band-pass')
ylabel('imag')
xlabel('real')

# signal and phase, detail
figure()
subplot(211)
plot(t[10000:13000], ecg_signal[10000:13000], 'b')
plot(t[10000:13000], signalHP[10000:13000], 'r')
plot(t[10000:13000], signalBP[10000:13000], 'g')
title('detailed signal')
ylabel('mV')
xlabel('time [s]')
legend(['original', 'high-pass', 'band-pass'])
subplot(212)
plot(t[10000:13000], phase[10000:13000], 'b')
plot(t[10000:13000], phaseHP[10000:13000], 'r')
plot(t[10000:13000], phaseBP[10000:13000], 'g')
title('detailed phase')
xlabel('time [s]')
ylabel('\phi')
legend(['original', 'high-pass', 'band-pass'])

# QRS peaks
figure()
subplot(211)
plot(t, signalHP)
plot(t[peakPos], zeros(len(peakPos)), 'rx', linewidth=2)
title('QRS complexes')
xlabel('time [s]')
ylabel('mV')

# QRS waves
subplot(212)
plot(t[:len(timeWindow)], waves.T)
plot(t[:len(timeWindow)], mean(waves, axis=0),
     linewidth=2, color=[0.3, 0.3, 0.3])
title('detailed QRS, single and average')
xlabel('time [s]')
ylabel('mV')

# isolate and plot QRS waves for all 8 channels

for iChan in range(8):

    ecg_signal = ecg_channels[iChan]
    b, a = filterHP['ba']
    signalHP = sig.filtfilt(b, a, ecg_signal)
    windows = peakPos[1:-1].reshape(-1, 1) + timeWindow
    waves = signalHP[windows]

    figure('QRS')
    subplot(4, 2, iChan + 1)
    plot(t[:len(timeWindow)], waves.T)
    plot(t[:len(timeWindow)], mean(waves, axis=0),
         linewidth=2, color=[.3, .3, .3])
    title('QRS ch %s' % (iChan + 1))
    xlabel('time [s]')
    ylabel('mV')

    figure('QRS all channels')
    plot(t[:len(timeWindow)], mean(waves, axis=0),
         linewidth=2, color=[iChan * 0.1] * 3)
    xlabel('time [s]')
    ylabel('mV')

show()
