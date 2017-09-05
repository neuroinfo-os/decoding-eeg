from pylab import *
from numpy.random import shuffle
import statsmodels.api as sm
from sklearn import svm


def modelFitVal2(X, L, kPart, modelType):
    """
    modelFitVal2 takes multivariate data (one feature per column) and
    associated labels and returns the cross-validated performance of the
    specified type of model.

    set up shuffled data partitions

    """

    print("shapes", X.shape, L.shape)

    nSamples = len(X)
    partTag = repeat(arange(kPart), nSamples // kPart)
    shuffle(partTag)

    pCorrect = 0

    for iPart in range(kPart):

        # separate training and test data
        index = (partTag == iPart)
        xTest = X[index]
        lTest = L[index]
        xTrain = X[~index]
        lTrain = L[~index]

        # fit and validate model
        if modelType == 'logit':
            xTest = sm.add_constant(xTest)
            xTrain = sm.add_constant(xTrain)
            model = sm.GLM(lTrain, xTrain, family=sm.families.Binomial())
            model_fit = model.fit()
            posterior_C1 = model_fit.predict(xTest)

        elif modelType == 'linsvm':
            model = svm.SVC(kernel='linear')
            model.fit(xTrain, lTrain)
            posterior_C1 = model.predict(xTest)

        elif modelType == 'rbfsvm':
            model = svm.SVC(kernel='rbf')
            model.fit(xTrain, lTrain)
            posterior_C1 = model.predict(xTest)

        else:
            raise ValueError('Unknown model type.')

        pr = posterior_C1.round()
        #print(list(zip(posterior_C1.round(), lTest)))
        print('shapes asdk', lTest.shape, pr.shape)

        # compare model's classification to actual labels
        pCorrect += mean(posterior_C1.round() == lTest.flatten())

    return pCorrect / kPart
