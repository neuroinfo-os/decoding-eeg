function pCorrect = modelFitVal_solution(X, L, k)

% modelFitVal takes multivariate data (one feature per column) and
% associated labels and returns the cross-validated performance of a linear
% model.

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
    % fit model to training data using logistic regression
    coeff = glmfit(xTrain, lTrain, 'binomial', 'link', 'logit');
    % compute labels for test data from rounded p(C1|D)
    lPredicted = round(glmval(coeff, xTest, 'logit'));
    % compare predicted to actual labels
    pCorrect = pCorrect + 1/k*mean(lPredicted==lTest);
end
