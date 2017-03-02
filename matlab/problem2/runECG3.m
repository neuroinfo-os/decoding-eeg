% -------------------------------------------------------------------------
% real data, 2 blocks, 3 features * 2 time points, classification
% -------------------------------------------------------------------------

clear
close all

% sampling frequency is 512 Hz
f_s = 512;

% load filters
load('filterHP_0.5_1.5.mat')
load('filterLP_3_10.mat')


%% analyze

% phase locking pack size
packSize = 25;

% we want to discriminate blocks 2 and 7
useBlocks = [2 7];

% initialize feature structure
Features = struct('PhaseHP', [], 'PhaseBP', [], 'PLVHP', []);

for B=1:2
    
    % load data, get signal from channel 3
    load(['block_' num2str(useBlocks(B))])
    signal = block_data(:, 3);
    
    % create high-pass and band-pass filtered signals by combining filters
    signalHP = ...
    signalBP = ...
    
    % extract QRS complex positions, using the high-pass filtered signal
    [H2, HDR, s] = qrsdetect(signalHP, f_s, 1);
    peakPos = H2.EVENT.POS;
    
    % compute phases for the high-pass and band-pass filtered signals
    phaseHP = ...
    phaseBP = ...
    
    % isolate phases. define a time window around each QRS peak, cut out
    % the single phase epochs (unwrapped high-pass and band-pass filtered
    % phases), align each epoch to its value at the time of the QRS peak,
    % and stack them into matrices. leave out the first and last epoch to
    % avoid indexing errors
    timeWindow = ...
    phasesHP = zeros(length(timeWindow), length(peakPos)-2);
    phasesBP = zeros(length(timeWindow), length(peakPos)-2);
    for iEpoch=2:(length(peakPos)-1)
        tmp = unwrap(...);
        phasesHP(:, iEpoch-1) = tmp - ...
        tmp = unwrap(...);
        phasesBP(:, iEpoch-1) = tmp - ...
    end
    
    % compute phase locking values over time. for each pack of epochs of
    % the high-pass filtered signal's unwrapped phase, compute the average
    % phase angle similarity per time point over epochs, to obtain one PLV
    % time series per pack
    nPacks = floor(size(phasesHP, 2)/packSize);
    plvHP = zeros(length(timeWindow), nPacks);
    for iPack=1:nPacks
        thisPack = ...
        plvHP(:, iPack) = ...
    end
    
    % store features
    Features(B).PhaseHP = phasesHP;
    Features(B).PhaseBP = phasesBP;
    Features(B).PLVHP = plvHP;
    
end


%% classify

% specify epochs to use. the number of epochs should be a multiple of
% packSize, to exclude incomplete data
useEpochs = ...
nEpochs = length(useEpochs);

% define 2 sample time points around the QRS complex and the T-wave,
% respectively. note that exactly at the QRS peak phases are set to zero
t1 = ...
t2 = ...

% construct the feature matrix for each block. each of the nEpochs rows
% should contain 6 features: the 3 features stored above, each sampled at
% the 2 time points. note that PLVs must be copied to fill the rows
X = [];
feat = zeros(nEpochs, 6);
for B=1:2
    feat(:, 1) = ...
    feat(:, 2) = ...
    ...
    
    X = [X; feat];
end

% train and validate logit model, linear SVM, and RBF SVM (nothing to
% change here)
kCross = 5;
L = [ones(nEpochs, 1); zeros(nEpochs, 1)];
modelType = {'logreg', 'linsvm', 'rbfsvm'};
for iModel=1:3
    pCorrect = modelFitVal2(X, L, kCross, modelType{iModel});
    fprintf('\nPerformance %6s: %3i percent\n', ...
        modelType{iModel}, round(100*pCorrect));
end
