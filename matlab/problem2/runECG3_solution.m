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
    signalHP = filtfilt(filterHP.Numerator, 1, signal);
    signalBP = filtfilt(filterLP.Numerator, 1, signalHP);
    
    % extract QRS complex positions, using the high-pass filtered signal
    [H2, HDR, s] = qrsdetect(signalHP, f_s, 1);
    peakPos = H2.EVENT.POS;
    
    % compute phases
    phaseHP = angle(hilbert(signalHP));
    phaseBP = angle(hilbert(signalBP));
    
    % isolate phases
    timeWindow = round(-0.2*f_s)+1:round(0.6*f_s);
    phasesHP = zeros(length(timeWindow), length(peakPos)-2);
    phasesBP = zeros(length(timeWindow), length(peakPos)-2);
    for iEpoch=2:(length(peakPos)-1)
        tmp = unwrap(phaseHP(peakPos(iEpoch)+timeWindow));
        phasesHP(:, iEpoch-1) = tmp - tmp(timeWindow==0);
        tmp = unwrap(phaseBP(peakPos(iEpoch)+timeWindow));
        phasesBP(:, iEpoch-1) = tmp - tmp(timeWindow==0);
    end
    
    % compute phase locking values over time
    nPacks = floor(size(phasesHP, 2)/packSize);
    plvHP = zeros(length(timeWindow), nPacks);
    for iPack=1:nPacks
        thisPack = (iPack-1)*packSize + (1:packSize);
        plvHP(:, iPack) = abs(mean(exp(1i*phasesHP(:, thisPack)), 2));
    end
    
    % store features
    Features(B).PhaseHP = phasesHP;
    Features(B).PhaseBP = phasesBP;
    Features(B).PLVHP = plvHP;
    
end


%% classify

% specify epochs to use
useEpochs = ...
    1:packSize*min(size(Features(1).PLVHP, 2), size(Features(2).PLVHP, 2));
nEpochs = length(useEpochs);

% define sample time points
t1 = round((0.2 + 0.03)*f_s);
t2 = round((0.2 + 0.29)*f_s);

% construct feature matrix for each block
X = [];
feat = zeros(nEpochs, 6);
for B=1:2
    feat(:, 1) = Features(B).PhaseHP(t1, useEpochs);
    feat(:, 2) = Features(B).PhaseHP(t2, useEpochs);
    feat(:, 3) = Features(B).PhaseBP(t1, useEpochs);
    feat(:, 4) = Features(B).PhaseBP(t2, useEpochs);
    tmp = Features(B).PLVHP(t1, :);
    tmp = reshape(repmat(tmp, packSize, 1), 1, []);
    feat(:, 5) = tmp(useEpochs);
    tmp = Features(B).PLVHP(t2, :);
    tmp = reshape(repmat(tmp, packSize, 1), 1, []);
    feat(:, 6) = tmp(useEpochs);
    X = [X; feat];
end

% train and validate logit model, linear SVM, and RBF SVM
kCross = 5;
L = [ones(nEpochs, 1); zeros(nEpochs, 1)];
modelType = {'logreg', 'linsvm', 'rbfsvm'};
for iModel=1:3
    pCorrect = modelFitVal2_solution(X, L, kCross, modelType{iModel});
    fprintf('\nPerformance %6s: %3i percent\n', ...
        modelType{iModel}, round(100*pCorrect));
end
