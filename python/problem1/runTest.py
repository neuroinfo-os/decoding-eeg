"""
This script samples data from two bivariate normal distributions, calls
classification functions for two classes, and plots the results.
"""

from pylab import *
from scipy.stats import multivariate_normal
import statsmodels.api as sm

from modelFitVal import modelFitVal

# set sample size, means, and covariance matrix
nSamples = 500
mu_1 = [1, 3]
mu_2 = [3, 0]
sigma = [[ 2.0,  1.5],
         [ 1.5,  2.0]]

# sample data from both distributions and create labels
X1 = ...
X2 = ...
X = vstack([X1, X2])
L = ...

# compute representative densities of underlying distributions
xVector = linspace(X.min(), X.max(), 100)
...
p_X1 = ...
p_X2 = ...
pDist = reshape(p_X1 + p_X2, 100, 100)

# fit GLM using logistic regression
coeff = ...

# determine the decision boundary of the fitted model
x2db = ...

# compute representative class posteriors
posterior_C1 = ...
posterior_C1 = posterior_C1.reshape(100, 100)

# cross-validate the same model to estimate generalization
kCross = 10
pCorrect = modelFitVal(X, L, kCross)


# ----------- plotting (nothing to change here) ---------------- #

# plot data, distributions, and decision boundary
figure(figsize=[10,10])
imshow(rot90(pDist.T), extent=(X.min(), X.max())*2, cmap='gray')
scatter(*X1.T, color='red', marker='x')
scatter(*X2.T, color='blue', marker='x')
plot(xVector, x2db, color='green')
ylim((X.min(), X.max()))
xlim((X.min(), X.max()))
title('Data and Densities')

# plot posterior C1
figure()
imshow(rot90(posterior_C1.T), extent=(X.min(), X.max())*2, cmap='jet')
ylim(X.min(), X.max()); xlim(X.min(), X.max())
title('Posterior p(C1|X)')

show()

# print performance
print('\nPerformance: %s percent\n\n' % round(100*pCorrect))
