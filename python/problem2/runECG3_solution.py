"""
real data, 2 blocks, 3 features * 2 time points, classification

"""

from pylab import *
from scipy.io import loadmat
import scipy.signal as sig

from modelFitVal2 import modelFitVal2
from rpeakdetect import detect_beats

# sampling frequency is 512 Hz
f_s = 512

# load filters designed with pyfda
filterHP = load('highpass_filter.npz')
filterLP = load('lowpass_filter.npz')

# analyze

# phase locking pack size
packSize = 25

# we want to discriminate blocks 2 and 7
useBlocks = [2, 7]

Features = {}

for B in [0, 1]:
    print('Process block', useBlocks[B])

    # load data, get signal from channel 3
    block_data = loadmat('../../data/ECG/block_' + str(useBlocks[B]))
    block_data = block_data['block_data'].T
    ecg_signal = block_data[2]
    ecg_signal = ecg_signal.astype('float64')

    # create high-pass and band-pass filtered signals by combining filters
    b, a = filterHP['ba']
    signalHP = sig.filtfilt(b, 1.0, ecg_signal)
    b, a = filterLP['ba']
    signalBP = sig.filtfilt(b, 1.0, signalHP)

    # extract QRS complex positions, using the high-pass filtered signal
    peakPos = detect_beats(signalHP, f_s)

    # compute phases by getting the angle of the analytical signals
    phaseHP = angle(sig.hilbert(signalHP))
    phaseBP = angle(sig.hilbert(signalBP))

    # isolate phases. define a time window around each QRS peak, cut out
    # the single phase epochs (unwrapped high-pass and band-pass filtered
    # phases), align each epoch to its value at the time of the QRS peak,
    # and stack them into matrices. leave out the first and last epoch to
    # avoid indexing errors
    timeWindow = arange(round(-0.2 * f_s), round(0.6 * f_s))
    windows = peakPos[1:-1].reshape(-1, 1) + timeWindow
    phasesHP = unwrap(phaseHP[windows])
    phasesHP -= phasesHP[:, timeWindow == 0]
    phasesBP = unwrap(phaseBP[windows])
    phasesBP -= phasesBP[:, timeWindow == 0]

    # compute phase locking values over time
    packNumber = len(phasesHP) // packSize
    packs = arange(packNumber * packSize)
    packs = reshape(packs, [packNumber, packSize])
    plvHP = phasesHP[packs]
    plvHP = abs(mean(exp(1j * plvHP), axis=1))

    Features[B] = {
        'PhaseHP': phasesHP,
        'PhaseBP': phasesBP,
        'PLVHP': plvHP,
    }


# ---- classify ---- #

# specify epochs to use. (number of epochs should be a multiple of
# packSize)
useEpochs = range(
    packSize * min(len(Features[0]['PLVHP']),
                   len(Features[1]['PLVHP'])))
nEpochs = len(useEpochs)

# define 2 sample time points around the QRS complex and the T-wave,
# respectively. note that at exactly 200 ms phases are set to zero!
t1 = round((0.2 + 0.03) * f_s)
t2 = round((0.2 + 0.29) * f_s)

print('construct feature matrix')  # for each block
featureMatrix = {}
for B in [0, 1]:
    feat = empty([nEpochs, 6])
    feat[:, 0] = Features[B]['PhaseHP'][useEpochs, t1]
    feat[:, 1] = Features[B]['PhaseHP'][useEpochs, t2]
    feat[:, 2] = Features[B]['PhaseBP'][useEpochs, t1]
    feat[:, 3] = Features[B]['PhaseBP'][useEpochs, t2]
    tmp = Features[B]['PLVHP'][:, t1]
    print('tmpshape1', tmp.shape)
    tmp = repeat(tmp, packSize)
    print('tmpshape2', tmp.shape)
    feat[:, 4] = tmp[useEpochs]
    tmp = Features[B]['PLVHP'][:, t2]
    tmp = repeat(tmp, packSize)
    feat[:, 5] = tmp[useEpochs]
    featureMatrix[B] = feat


# set number of cross-validation cycles
kCross = 5

# train and validate logit model, linear SVM, and RBF SVM
X = vstack([featureMatrix[0], featureMatrix[1]])
L = vstack([ones([nEpochs, 1]), zeros([nEpochs, 1])])
print(X.shape, L.shape)
for modelType in ['logit', 'linsvm', 'rbfsvm']:
    pCorrect = modelFitVal2(X, L, kCross, modelType)
    print('\nPerformance {}: {}%\n'.format(
        modelType,
        round(100 * pCorrect)))
