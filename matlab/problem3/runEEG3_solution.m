% -------------------------------------------------------------------------
% 2 blocks, 1 channel, ..., feature extraction, classification
% -------------------------------------------------------------------------

clear
close all

% sampling frequency is 5 kHz
f_s = 5000;

% load filter. use fdatool to build filter first
load('filterLP_1000_1200.mat')


%% analyze

% phase locking pack size
packSize = 20;

% specify blocks to analyze and channel to use
useBlocks = [1 3];
useChan = 7;

% initialize feature structure
Features = struct('Power', [], 'PLV', []);

for B=1:2
    
    % load and reshape data, get dimensions
    load(['block' num2str(useBlocks(B))])
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
    
    % store features
    Features(B).Power = Power;
    Features(B).PLV = PLV;

end


%% classify

% specify sweeps to use
useSweeps = ...
    1:packSize*min(size(Features(1).PLV, 2), size(Features(2).PLV, 2));
nSweeps = length(useSweeps);

% define 5 sample points to capture BAEP wave V of the middle sweep
t = (5:9)/1000*f_s + 512;

% specify which of the 7 MRA scales to use
useScales = [1 2 4 5];
nScales = length(useScales);

% construct the feature matrix
X = [];
for B=1:2
    feat = [];
    for iScale=1:nScales
        feat = [feat, Features(B).Power(t, useSweeps, useScales(iScale))'];
        tmp = Features(B).PLV(t, :, useScales(iScale));
        tmp = reshape(repmat(tmp, packSize, 1), 5, []);
        feat = [feat, tmp(:, useSweeps)'];
    end
    X = [X; feat];
end

% train and validate the models
kCross = 5;
L = [ones(nSweeps, 1); zeros(nSweeps, 1)];
modelType = {'logreg', 'linsvm', 'rbfsvm'};
for iModel=1:3
    pCorrect = modelFitVal3_solution(X, L, kCross, modelType{iModel});
    fprintf('\nPerformance %6s: %3i %%\n', ...
        modelType{iModel}, round(100*pCorrect));
end
