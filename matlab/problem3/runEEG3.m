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
useChan = ...

% initialize feature structure
Features = struct('Power', [], 'PLV', []);

for B=1:2
    
    % load and reshape data, get dimensions
    load(['block' num2str(useBlocks(B))])
    signal = squeeze(EEG.data(useChan, :, :));
    [nPts, nSweeps] = size(signal);
    
    % filter the signal. apply your low-pass filter and a 50 Hz notch
    % filter (using function cleanAC), then correct for baseline (subtract
    % from each epoch its mean signal over 100 pt around the 2nd sweep
    % onset)
    ...
    signal = ...
    
    % compute wavelet transform
    sWT = MRA_stationary_fast(signal, 'db4', f_s);
    
    % compute instantaneous phase and power for all sweeps and scales (no
    % need to leave out the first and last trials here, since the data are
    % already epoched). correct phases for the middle sweep's baseline
    Power = zeros(nPts, nSweeps, 7);
    Phase = zeros(nPts, nSweeps, 7);
    for iScale=1:7
        ...
        Power(:, :, iScale) = ...
        ...
        Phase(:, :, iScale) = ...
    end

    % compute phase locking values
    nPacks = floor(nSweeps/packSize);
    PLV = zeros(nPts, nPacks, 7);
    for iPack=1:nPacks
        thisPack = ...
        PLV(:, iPack, :) = ...
    end
    
    % store features
    Features(B).Power = Power;
    Features(B).PLV = PLV;

end


%% classify

% specify sweeps to use
useSweeps = ...
nSweeps = length(useSweeps);

% define 5 sample points to capture BAEP wave V of the middle sweep
t = ...

% specify which of the 7 MRA scales to use as features
useScales = ...
nScales = length(useScales);

% construct the feature matrix, using power and PLV for each time point and
% scale. each row should contain 2*5*nScales entries. for simplicity, the
% suggested code fills the rows by appending rather than explicit indexing
X = [];
for B=1:2
    feat = [];
    for iScale=1:nScales
        feat = [feat, ...];
        ...
    end
    X = [X; feat];
end

% train and validate the models (nothing to change here)
kCross = 5;
L = [ones(nSweeps, 1); zeros(nSweeps, 1)];
modelType = {'logreg', 'linsvm', 'rbfsvm'};
for iModel=1:3
    pCorrect = modelFitVal3(X, L, kCross, modelType{iModel});
    fprintf('\nPerformance %6s: %3i %%\n', ...
        modelType{iModel}, round(100*pCorrect));
end
