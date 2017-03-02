"""
This script samples data from two bivariate normal distributions, calls
classification functions for two classes, and plots the results.
"""

from pylab import *
from scipy.stats import multivariate_normal
import statsmodels.api as sm

from modelFitVal_solution import modelFitVal

# set sample size, means, and covariance matrix
nSamples = 500
mu_1 = [1, 3]
mu_2 = [3, 0]
sigma = [[ 2.0,  1.5],
         [ 1.5,  2.0]]

# create distributions
dist1 = multivariate_normal(mu_1, sigma)
dist2 = multivariate_normal(mu_2, sigma)

# sample data from both distributions and create labels
X1 = dist1.rvs(nSamples)
X2 = dist2.rvs(nSamples)
X = vstack([X1, X2])
L = hstack([ones(nSamples), zeros(nSamples)]) #.reshape(-1,1)

# compute representative densities of underlying distributions
xVector = linspace(X.min(), X.max(), 100)
xx = transpose([tile(xVector, 100), repeat(xVector, 100)])
pDist = dist1.pdf(xx) + dist2.pdf(xx)
pDist = pDist.reshape(100, 100)

# fit GLM using logistic regression
X = sm.add_constant(X)
model = sm.GLM(L, X, family=sm.families.Binomial())
model_fit = model.fit()

# determine the decision boundary of the fitted model
c1, c2, c3 = model_fit.params
x2db = (-log(0.5) - c2*xVector - c1) / c3

# compute representative class posteriors
posterior_C1 = model_fit.predict(sm.add_constant(xx))
posterior_C1 = posterior_C1.reshape(100, 100)

# cross-validate the same model to estimate generalization
kCross = 10
pCorrect = modelFitVal(X, L, kCross)


# --------------------- plotting ------------------------ #

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
