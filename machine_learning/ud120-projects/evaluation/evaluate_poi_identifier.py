#!/usr/bin/python


"""
    Starter code for the evaluation mini-project.
    Start by copying your trained/tested POI identifier from
    that which you built in the validation mini-project.

    This is the second step toward building your POI identifier!

    Start by loading/formatting the data...
"""

import pickle
import sys
sys.path.append("../tools/")
from feature_format import featureFormat, targetFeatureSplit
from sklearn.metrics import accuracy_score
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score 
from sklearn import tree
from sklearn.cross_validation import train_test_split

data_dict = pickle.load(open("../final_project/final_project_dataset.pkl", "r") )

### add more features to features_list!
features_list = ["poi", "salary"]

data = featureFormat(data_dict, features_list)
labels, features = targetFeatureSplit(data)



### your code goes here 
features_train, features_test, labels_train, labels_test = \
train_test_split(features,  labels, test_size=0.3, random_state=42)


clf = tree.DecisionTreeClassifier()
clf = clf.fit(features_train, labels_train)

pred =  clf.predict(features_test)

acc = accuracy_score(pred, labels_test)

print(acc)

#Quiz: Number Of POIs In Test Set
n=0
for label in labels_test:
    if label==1:
        n+=1
print 'Number Of POIs In Test Set:', n

#Quiz: Number Of People In Test Set
print len(features_test)


#Quiz: Accuracy Of A Biased Identifier
#If your identifier predicted 0. (not POI) for everyone in the test set, what would its accuracy be?
acc = accuracy_score(pred,  [0.]*29)

print(acc)


#Quiz: Number Of True Positives
count=0
for i,j in zip(pred,labels_test):
    if i==j==1:
        count+=1
print 'True positives:', count

#Quiz: Unpacking Into Precision And Recall
print 'precision_score:', precision_score(labels_test, pred)
print 'recall_score:', recall_score(labels_test, pred) 


#