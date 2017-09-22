function pCorrect = modelFitVal_solution(X, L, k)

% modelFitVal takes multivariate data (one feature per column) and
% associated labels and returns the cross-validated performance of a linear
% model.

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
    % fit logit model to training data
    coeff = glmfit(xTrain, lTrain, 'binomial', 'link', 'logit');
    % compute labels for test data from rounded p(C1|D)
    lPredicted = round(glmval(coeff, xTest, 'logit'));
    % compare predicted to actual labels
    pCorrect = pCorrect + 1/k*mean(lPredicted==lTest);
end
