function pCorrect = modelFitVal(X, L, k)

% modelFitVal takes multivariate data (one feature per column) and
% associated labels and returns the cross-validated performance of a linear
% model.

% create a random permutation of sample indices
nSamples = size(X, 1);
randIdx = ...

% initialize performance measure
pCorrect = 0;

for iPart=1:k
    % construct 2 vectors of indices that divide the samples into
    % validation and training set of size nSamples/k and (k-1)*nSamples/k,
    % respectively. for uneven divisions, make sure set sizes never differ
    % by more than 1 over all iterations
    idxTest = ...
    idxTrain = ...
    % select data and labels using the above index vectors
    xTest = X(...);
    xTrain = X(...);
    lTest = L(...);
    lTrain = L(...);
    % fit logit model to training data
    coeff = glmfit(...);
    % compute labels for test data from rounded p(C1|D)
    lPredicted = round(...);
    % compare predicted to actual labels and accumulate performance
    pCorrect = pCorrect + 1/k*mean(lPredicted==lTest);
end
