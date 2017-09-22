from pylab import *
from numpy.random import shuffle
from sklearn.linear_model import LogisticRegression


def modelFitVal(X, L, kPart):
    """
    modelFitVal takes multivariate data (one feature per column) and
    associated labels and returns the cross-validated performance of a linear
    model.

    """

    # set up shuffled data partitions
    nSamples = len(X)
    partTag = arange(nSamples) % kPart
    shuffle(partTag)

    pCorrect = 0

    for iPart in range(kPart):

        # separate training and test data
        index = (partTag == iPart)
        xTest = X[index]
        lTest = L[index]
        xTrain = X[~index]
        lTrain = L[~index]
        
        # fit model to training data using logistic regressio
        model = LogisticRegression()
        model.fit(xTrain, lTrain)

        # compute p(C1|D) for test data
        posterior_C1 = model.predict(xTest)

        # compare model's classification to actual labels
        pCorrect += mean(posterior_C1 == lTest) / kPart

    return pCorrect
