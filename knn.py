#! /usr/bin/python

import numpy as np
from sklearn import neighbors, datasets
import pandas as pd    
 
df = pd.read_table("knn.csv", sep = ",")
#target = pd.read_table("target.csv", sep = ",")
X = df.iloc[:, 1:6]
y = df["category_predict"]

# k : number of neighbors
k = 500
clf = neighbors.KNeighborsClassifier(n_neighbors = k, n_jobs = -1, weights = "distance", p = 2)
clf.fit(X, y)
#Z = clf.predict(X)
#accuracy = clf.score(X, y)
prob = clf.predict_proba(xTest)
prob = pd.DataFrame(prob)
#print prob
prob.to_csv("resultsKnn.csv", sep = ",", doublequote = False)

print "Predicted model accuracy: " + str(accuracy) + " for k = " + str(k)

# score kaggle : 4.17438