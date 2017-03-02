% -------------------------------------------------------------------------
% This script samples data from two bivariate normal distributions, calls
% classification functions for two classes, and plots the results.
% -------------------------------------------------------------------------

close all
clear

% set sample size, means, and covariance matrix
nSamples = 500;
mu_1 = [1,3];
mu_2 = [3,0];
sigma = [2.0 1.5
         1.5 2.0];

% sample data from both distributions and create labels
X1 = mvnrnd(mu_1, sigma, nSamples);
X2 = mvnrnd(mu_2, sigma, nSamples);
X = [X1; X2];
L = [ones(nSamples, 1); zeros(nSamples, 1)];

% compute representative densities of underlying distributions
xVector = linspace(min(X(:)), max(X(:)), 100);
[x1mesh, x2mesh] = meshgrid(xVector, xVector);
p_X1 = mvnpdf([x1mesh(:) x2mesh(:)], mu_1, sigma);
p_X2 = mvnpdf([x1mesh(:) x2mesh(:)], mu_2, sigma);
pDist = reshape(p_X1 + p_X2, 100, 100);

% fit GLM using logistic regression
coeff = glmfit(X, L, 'binomial', 'link', 'logit');

% determine the decision boundary of the fitted model
x2db = -(coeff(2)*xVector + coeff(1)) / coeff(3);

% compute representative class posteriors
posterior_C1 = ...
    glmval(coeff, [x1mesh(:) x2mesh(:)], 'logit');
posterior_C1 = reshape(posterior_C1, 100, 100);

% cross-validate the same model to estimate generalization
kCross = 10;
pCorrect = modelFitVal_solution(X, L, kCross);


%% plot

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
pcolor(xVector, xVector, posterior_C1)
axis square
shading flat
title('Posterior P(C_1|x)')

% print performance
fprintf('\nPerformance: %3i percent\n\n', round(100*pCorrect));
