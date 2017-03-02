function pCorrect = modelFitVal2(X, L, k, modelType)

% modelFitVal2 takes multivariate data (one feature per column) and
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
    disp([length(idxTest) length(idxTrain)])
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
