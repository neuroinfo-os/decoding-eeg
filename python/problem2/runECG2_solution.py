"""
real data, 8 blocks, more processing, feature plotting

"""

from time import time
import sys

from pylab import *
from scipy.io import loadmat
import scipy.signal as sig

from rpeakdetect import detect_beats

rcParams.update({
    'legend.fontsize' : 'small',
    'legend.labelspacing' : 0.1,
})


# sampling frequency is 512 Hz
f_s = 512

# load filters designed with pyfda
filterHP = load('highpass_filter.npz')
filterLP = load('lowpass_filter.npz')

# phase locking pack size
packSize = 25

# analyze blocks 1 to 8
for B in range(1, 9):
    filepath = '../../data/ECG/block_%s' % B
    print('Processing block', B, end=' ')
    sys.stdout.flush()
    tic = time()

    # load data, get signal from channel 3, create time vector
    block_data = loadmat(filepath)
    block_data = block_data['block_data'].T
    ecg_signal = block_data[2]
    ecg_signal = ecg_signal.astype('float64')
    t = arange(len(ecg_signal)) / f_s

    # create high-pass and band-pass filtered signals by combining filters
    b, a = filterHP['ba']
    signalHP = sig.filtfilt(b, 1.0, ecg_signal)
    # b, a = filterLP['ba']
    signalBP = sig.filtfilt(b, 1.0, signalHP)

    # extract QRS complex positions, using the high-pass filtered signal
    peakPos = detect_beats(signalHP, f_s)

    # compute phases by getting the angle of the analytical signals
    phaseHP = angle(sig.hilbert(signalHP))
    phaseBP = angle(sig.hilbert(signalBP))

    # isolate QRS waves and phases of the high-pass filtered signal. define
    # a time window around each QRS peak, cut out the single epochs, and
    # stack them into matrices. align each signal epoch to its mean and
    # each phase epoch to its value at the time of the QRS peak. leave out
    # the first and last epoch to avoid indexing errors
    timeWindow = arange(round(-0.2 * f_s), round(0.6 * f_s))
    windows = peakPos[1:-1].reshape(-1, 1) + timeWindow
    waves = signalHP[windows]
    waves -= mean(waves, axis=0)
    phases = unwrap(phaseHP[windows])
    phases -= phases[:, timeWindow == 0]

    # compute phase locking values over time
    packNumber = len(phases) // packSize
    packs = arange(packNumber * packSize)
    packs = reshape(packs, [packNumber, packSize])
    plv = phases[packs]
    plv = abs(mean(exp(1j * plv), axis=1))

    # ----- plot ----- #
    blk = ' block %s' % B

    # show first 4 seconds of signal and phase
    t0 = 1
    t1 = int(4 * f_s)

    # signal detailed
    figure('detailed signal')
    subplot(4, 2, B)
    plot(t[t0:t1], ecg_signal[t0:t1], 'r')
    plot(t[t0:t1], signalBP[t0:t1], 'g')
    xlim([t[t0], t[t1]])
    title(blk)
    ylabel('mV')
    xlabel('time [s]')
    legend(['high-pass', 'band-pass'])

    # phase detailed
    figure('detailed phase')
    subplot(4, 2, B)
    plot(t[t0:t1], phaseHP[t0:t1], 'r')
    plot(t[t0:t1], phaseBP[t0:t1], 'g')
    xlim([t[t0], t[t1]])
    title(blk)
    ylabel('$\phi$')
    xlabel('time [s]')
    legend(['high-pass', 'band-pass'])

    # QRS waves
    figure('QRS')
    subplot(4, 2, B)
    plot(t[:len(timeWindow)], waves.T)
    plot(t[:len(timeWindow)], mean(waves, axis=0),
         linewidth=2, color=[.3, .3, .3])
    xlim([t[0], t[len(timeWindow)]])
    title(blk)
    ylabel('mV')
    xlabel('time [s]')

    # phase locking values
    figure('phase locking')
    subplot(4, 2, B)
    imshow(plv, extent=[0, 1, 0, 1], cmap='jet')
    clim([0, 1])
    ylabel('pack no.')
    xlabel('time [pt]')
    title(blk)

    toc = time()
    print('(%s sec)' % round(toc - tic, 1))

show()
