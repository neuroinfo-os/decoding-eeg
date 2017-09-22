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
    signalHP = filtfilt(filterHP, 1, signal);
    signalBP = filtfilt(filterLP, 1, signalHP);
    
    % extract QRS complex positions, using the high-pass filtered signal
    [H2, HDR, s] = qrsdetect(signalHP, srate, 1);
    peakPos = H2.EVENT.POS;
    
    % compute phases
    phaseHP = angle(hilbert(signalHP));
    phaseBP = angle(hilbert(signalBP));
    
    % isolate phases
    timeWindow = round(-0.2*srate)+1:round(0.6*srate);
    phasesHP = nan(length(timeWindow), length(peakPos)-2);
    phasesBP = nan(length(timeWindow), length(peakPos)-2);
    for iEpoch=2:(length(peakPos)-1)
        tmp = unwrap(phaseHP(peakPos(iEpoch)+timeWindow));
        phasesHP(:, iEpoch-1) = tmp - tmp(timeWindow==0);
        tmp = unwrap(phaseBP(peakPos(iEpoch)+timeWindow));
        phasesBP(:, iEpoch-1) = tmp - tmp(timeWindow==0);
    end
    
    % compute phase locking values
    margin = floor(packSize/2);
    plvHP = nan(length(timeWindow), size(phasesHP, 2));
    for iEpoch=margin+1:size(plvHP, 2)-margin
        thisPack = iEpoch + (-margin:margin);
        plvHP(:, iEpoch) = abs(mean(exp(1i*phasesHP(:, thisPack)), 2));
    end
    
    % store features
    Features(B).PhaseHP = phasesHP(:, margin+1:end-margin);
    Features(B).PhaseBP = phasesBP(:, margin+1:end-margin);
    Features(B).PLVHP = plvHP(:, margin+1:end-margin);
    
end


%% classify ---------------------------------------------------------------

% define sample time points
t1 = round((0.2 + 0.03)*srate);
t2 = round((0.2 + 0.29)*srate);

% construct feature matrix for each block
nEpochs = min(size(Features(1).PhaseHP, 2), size(Features(2).PhaseHP, 2));
X = nan(2*nEpochs, 6);
for B=1:2
    rows = (B-1)*nEpochs + (1:nEpochs);
    X(rows, 1) = Features(B).PhaseHP(t1, 1:nEpochs);
    X(rows, 2) = Features(B).PhaseHP(t2, 1:nEpochs);
    X(rows, 3) = Features(B).PhaseBP(t1, 1:nEpochs);
    X(rows, 4) = Features(B).PhaseBP(t2, 1:nEpochs);
    X(rows, 5) = Features(B).PLVHP(t1, 1:nEpochs);
    X(rows, 6) = Features(B).PLVHP(t2, 1:nEpochs);
end

% train and validate logit model, linear SVM, and RBF SVM
kCross = 10;
L = [ones(nEpochs, 1); zeros(nEpochs, 1)];
modelType = {'logreg', 'linsvm', 'rbfsvm'};
for iModel=1:3
    pCorrect = modelFitVal2_solution(X, L, kCross, modelType{iModel});
    fprintf('\nPerformance %6s: %3i %%\n', ...
        modelType{iModel}, round(100*pCorrect));
end
