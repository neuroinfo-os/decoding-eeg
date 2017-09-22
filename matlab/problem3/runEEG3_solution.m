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
useChan = 7;

% initialize feature structure
Features = struct('Amp', [], 'PLV', []);

for B=1:2
    
    % load and reshape data, get dimensions
    load(['block' num2str(useBlocks(B))])
    signal = squeeze(EEG.data(useChan, :, :));
    [nPts, nEpochs] = size(signal);
    
    % filter the signal and correct for baseline
    signal = filtfilt(filterHP, 1, signal);
    signal = filtfilt(filterLP, 1, signal);
    signal = cleanAC(signal, 50, srate);
    baseline = mean(signal((-49:50)+512, :));
    signal = signal - repmat(baseline, nPts, 1);
    
    % compute wavelet transform
    sWT = MRA_stationary_fast(signal, 'db4', srate);
    
    % compute instantaneous phase and amplitude for all epochs and scales
    Amp = nan(nPts, nEpochs, 7);
    Phase = nan(nPts, nEpochs, 7);
    for iScale=1:7
        thisScale = sWT.scales(:, :, iScale);
        Amp(:, :, iScale) = abs(hilbert(thisScale));
        phaseTmp = unwrap(angle(hilbert(thisScale)));
        Phase(:, :, iScale) = phaseTmp - repmat(phaseTmp(512, :), nPts, 1);
    end
    
    % compute phase locking values
    margin = floor(packSize/2);
    PLV = nan(nPts, nEpochs, 7);
    for iEpoch=margin+1:nEpochs-margin
        thisPack = iEpoch + (-margin:margin);
        PLV(:, iEpoch, :) = abs(mean(exp(1i*Phase(:, thisPack, :)), 2));
    end
    
    % store features
    Features(B).Amp = Amp(:, margin+1:end-margin, :);
    Features(B).PLV = PLV(:, margin+1:end-margin, :);
    
end


%% classify ---------------------------------------------------------------

% define 5 sample points to capture BAEP wave V of the middle sweep
t = (5:9)/1000*srate + 512;

% construct the feature matrix
nEpochs = min(size(Features(1).Amp, 2), size(Features(2).Amp, 2));
X = nan(2*nEpochs, 70);
for B=1:2
    rows = (B-1)*nEpochs + (1:nEpochs);
    for iScale=1:7
        cols = (iScale-1)*10 + (1:10);
        X(rows, cols) = [Features(B).Amp(t, 1:nEpochs, iScale)', ...
            Features(B).PLV(t, 1:nEpochs, iScale)'];
    end
end

% train and validate the models
X = X * pcacov(cov(X)); % project data into principle component space
kCross = 10;
L = [ones(nEpochs, 1); zeros(nEpochs, 1)];
modelType = {'logreg', 'linsvm', 'rbfsvm'};
for iModel=1:3
    pCorrect = modelFitVal3_solution(X, L, kCross, modelType{iModel});
    fprintf('\nPerformance %6s: %3i %%\n', ...
        modelType{iModel}, round(100*pCorrect));
end
