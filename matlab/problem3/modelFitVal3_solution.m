function pCorrect = modelFitVal3_solution(X, L, k, modelType)

% modelFitVal3 takes multivariate data (one feature per column) and
% associated labels and returns the cross-validated performance of the
% specified type of model.

% shuffle the data
nSamples = size(X, 1);
r = randperm(nSamples);
X = X(r, :);
L = L(r);

pCorrect = 0;

for iPart=1:k
    % separate training and test data
    idxTest = iPart:k:nSamples;
    idxTrain = setdiff(1:nSamples, idxTest);
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
            'Standardize', 1, 'KernelScale', 2, 'BoxConstraint', 10);
        lPredicted = predict(svmTrained, xTest);
    elseif strcmp(modelType, 'rbfsvm')
        svmTrained = fitcsvm(xTrain, lTrain, 'KernelFunction', 'rbf', ...
            'Standardize', 1, 'KernelScale', 15, 'BoxConstraint', 100);
        lPredicted = predict(svmTrained, xTest);
    else
        error('Unknown model type.');
    end
    % compare predicted to actual labels
    pCorrect = pCorrect + 1/k*mean(lPredicted==lTest);
end
