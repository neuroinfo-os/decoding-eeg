% -------------------------------------------------------------------------
% This script samples data from two bivariate normal distributions, calls
% classification functions for two classes, and plots the results.
% -------------------------------------------------------------------------

close all
clear

% set sample size, means, and covariance matrix
nSamples = 500;
mu1 = [1,3];
mu2 = [3,0];
sigma = [2.0 1.5
         1.5 2.0];

% sample data from both distributions, concatenate them, and create labels
% for classification. rows should correspond to samples
X1 = ...
X2 = ...
X = [X1; X2];
L = ...

% compute representative densities of underlying distributions for 100*100
% X-values. hint: use functions meshgrid and mvnpdf.
xVector = linspace(min(X(:)), max(X(:)), 100);
...
pX1 = ...
pX2 = ...
pDist = reshape(pX1 + pX2, 100, 100);

% fit GLM using logistic regression
coeff = glmfit(...);

% determine the decision boundary of the fitted model
x2db = ...

% compute representative class posteriors for the 100*100 X-values
posteriorC1 = ...
posteriorC1 = reshape(posteriorC1, 100, 100);

% cross-validate the same model to estimate generalization
kCross = 10;
pCorrect = modelFitVal(X, L, kCross);


%% plot (nothing to change here) ------------------------------------------

% plot data, distributions, and decision boundary
figure('units','normalized','outerposition',[0.1 0.2 0.35 0.6])
colormap gray
pcolor(xVector, xVector, pDist)
hold on
plot(X1(:,1), X1(:,2), 'r.', X2(:,1), X2(:,2), 'b.');
plot(xVector, x2db, '-g')
shading flat
axis square
title('Data and Densities')

% plot posterior C1
figure('units','normalized','outerposition',[0.6 0.2 0.35 0.6])
colormap jet
pcolor(xVector, xVector, posteriorC1)
axis square
shading flat
title('Posterior P(C_1|x)')

% print performance
fprintf('\nPerformance: %3i %%\n\n', round(100*pCorrect));
