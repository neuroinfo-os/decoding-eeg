% -------------------------------------------------------------------------
% 2 blocks, 1 channel, ..., feature extraction, classification
% -------------------------------------------------------------------------

clear
close all

% sampling frequency is 5 kHz
srate = 5000;

% load filters
load('filterHP_0.1_10.mat')
load('filterLP_1000_1200.mat')


%% analyze ----------------------------------------------------------------

% phase locking pack size
packSize = 11;

% specify blocks to analyze and channel to use
useBlocks = [1 3];
useChan = ...

% initialize feature structure
Features = struct('Amp', [], 'PLV', []);

for B=1:2
    
    % load and reshape data, get dimensions
    load(['block' num2str(useBlocks(B))])
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

    % compute phase locking values
    margin = floor(packSize/2);
    PLV = nan(nPts, nEpochs, 7);
    for iEpoch=margin+1:nEpochs-margin
        thisPack = ...
        PLV(:, iEpoch, :) = ...
    end
    
    % store features
    Features(B).Amp = Amp(:, margin+1:end-margin, :);
    Features(B).PLV = PLV(:, margin+1:end-margin, :);

end


%% classify ---------------------------------------------------------------

% define 5 sample points to capture BAEP wave V of the middle sweep
t = ...

% construct the feature matrix, using amplitude and PLV for each time point
% and scale. we will use the same number of epochs for both blocks. each
% row should contain 2 * 5 * 7 = 70 entries
nEpochs = min(size(Features(1).Amp, 2), size(Features(2).Amp, 2));
X = nan(2*nEpochs, 70);
for B=1:2
    ...
end

% train and validate the models (nothing to change here)
kCross = 10;
L = [ones(nEpochs, 1); zeros(nEpochs, 1)];
modelType = {'logreg', 'linsvm', 'rbfsvm'};
for iModel=1:3
    pCorrect = modelFitVal3(X, L, kCross, modelType{iModel});
    fprintf('\nPerformance %6s: %3i %%\n', ...
        modelType{iModel}, round(100*pCorrect));
end
