% -------------------------------------------------------------------------
% real data, 2 blocks, 3 features * 2 time points, classification
% -------------------------------------------------------------------------

clear
close all

% sampling frequency is 512 Hz
srate = 512;

% load filters
load('filterHP_0.5_1.5.mat')
load('filterLP_3_10.mat')


%% analyze ----------------------------------------------------------------

% phase locking pack size
packSize = 11;

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
    [H2, HDR, s] = qrsdetect(signalHP, srate, 1);
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
    phasesHP = nan(length(timeWindow), length(peakPos)-2);
    phasesBP = nan(length(timeWindow), length(peakPos)-2);
    for iEpoch=2:(length(peakPos)-1)
        tmp = unwrap(...);
        phasesHP(:, iEpoch-1) = tmp - ...
        tmp = unwrap(...);
        phasesBP(:, iEpoch-1) = tmp - ...
    end
    
    % compute phase locking values over epochs. for each epoch of the
    % high-pass filtered signal's unwrapped phase, compute the PLV across
    % its symmetric neighborhood of epochs for each time point. ignore
    % early and late epochs without symmetric neighborhood
    margin = floor(packSize/2);
    plvHP = nan(length(timeWindow), size(phasesHP, 2));
    for iEpoch=margin+1:size(plvHP, 2)-margin
        thisPack = ...
        plvHP(:, iEpoch) = ...
    end
    
    % store features (reject epochs with undefined PLV)
    Features(B).PhaseHP = phasesHP(:, margin+1:end-margin);
    Features(B).PhaseBP = phasesBP(:, margin+1:end-margin);
    Features(B).PLVHP = plvHP(:, margin+1:end-margin);
    
end


%% classify ---------------------------------------------------------------

% define 2 sample time points around the QRS complex and the T-wave,
% respectively. note that exactly at the QRS peak phases are set to zero
t1 = ...
t2 = ...

% construct the feature matrix for each block. for simplicity, we will use
% the same number of epochs for both blocks. each row should contain 6
% features: the 3 features stored above, each sampled at the 2 time points
nEpochs = min(size(Features(1).PhaseHP, 2), size(Features(2).PhaseHP, 2));
X = nan(2*nEpochs, 6);
for B=1:2
    rows = (B-1)*nEpochs + (1:nEpochs);
    X(rows, 1) = ...
    X(rows, 2) = ...
    ...
end

% train and validate logit model, linear SVM, and RBF SVM (nothing to
% change here)
kCross = 10;
L = [ones(nEpochs, 1); zeros(nEpochs, 1)];
modelType = {'logreg', 'linsvm', 'rbfsvm'};
for iModel=1:3
    pCorrect = modelFitVal2(X, L, kCross, modelType{iModel});
    fprintf('\nPerformance %6s: %3i %%\n', ...
        modelType{iModel}, round(100*pCorrect));
end
