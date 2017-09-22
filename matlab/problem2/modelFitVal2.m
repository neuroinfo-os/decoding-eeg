function pCorrect = modelFitVal2(X, L, k, modelType)

% modelFitVal2 takes multivariate data (one feature per column) and
% associated labels and returns the cross-validated performance of the
% specified type of model.

% create a random permutation of sample indices
nSamples = size(X, 1);
randIdx = randperm(nSamples);

pCorrect = 0;

for iPart=1:k
    % separate training and test data
    idxTest = randIdx(iPart:k:nSamples);
    idxTrain = randIdx(setdiff(1:nSamples, idxTest));
    xTest = X(idxTest, :);
    xTrain = X(idxTrain, :);
    lTest = L(idxTest);
    lTrain = L(idxTrain);
    % fit and validate model. use appropriate functions for SVMs
    if strcmp(modelType, 'logreg')
        coeff = glmfit(xTrain, lTrain, 'binomial', 'link', 'logit');
        lPredicted = round(glmval(coeff, xTest, 'logit'));
    elseif strcmp(modelType, 'linsvm')
        ...
    elseif strcmp(modelType, 'rbfsvm')
        ...
    else
        error('Unknown model type.');
    end
    % compare predicted to actual labels
    pCorrect = pCorrect + 1/k*mean(lPredicted==lTest);
end
