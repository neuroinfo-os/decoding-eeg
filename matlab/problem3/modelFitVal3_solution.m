function pCorrect = modelFitVal3_solution(X, L, k, modelType)

% modelFitVal3 takes multivariate data (one feature per column) and
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
    % fit and validate model
    if strcmp(modelType, 'logreg')
        coeff = glmfit(xTrain, lTrain, 'binomial', 'link', 'logit');
        lPredicted = round(glmval(coeff, xTest, 'logit'));
    elseif strcmp(modelType, 'linsvm')
        svmTrained = fitcsvm(xTrain, lTrain, 'KernelFunction', 'linear', ...
            'Standardize', 1, 'KernelScale', 'auto');
        lPredicted = predict(svmTrained, xTest);
    elseif strcmp(modelType, 'rbfsvm')
        svmTrained = fitcsvm(xTrain, lTrain, 'KernelFunction', 'rbf', ...
            'Standardize', 1, 'KernelScale', 'auto');
        lPredicted = predict(svmTrained, xTest);
    else
        error('Unknown model type.');
    end
    % compare predicted to actual labels
    pCorrect = pCorrect + 1/k*mean(lPredicted==lTest);
end
