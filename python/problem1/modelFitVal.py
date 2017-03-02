from pylab import *
from numpy.random import shuffle
import statsmodels.api as sm


def modelFitVal(X, L, kPart):
    """
    modelFitVal takes multivariate data (one feature per column) and
    associated labels and returns the cross-validated performance of a linear
    model.

    """

    # set up shuffled data partitions
    nSamples = ...
    partTag = ...
    shuffle(partTag)

    pCorrect = 0

    for iPart in range(kPart):

        # separate training and test data
        index = ...
        xTest = X[...]
        lTest = L[...]
        xTrain = X[~...]
        lTrain = L[~...]

        # add columns of ones
        xTest = sm.add_constant(xTest)
        xTrain = sm.add_constant(xTrain)

        # fit model to training data using logistic regression
        model = sm.GLM(...)
        model = ...

        # compute p(C1|D) for test data
        posterior_C1 = model.predict(xTest)

        # compare model's classification to actual labels
        pCorrect += mean(posterior_C1.round() == lTest) / kPart

    return pCorrect
