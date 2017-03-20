#!/usr/bin/python

"""
    Starter code for the regression mini-project.
    
    Loads up/formats a modified version of the dataset
    (why modified?  we've removed some trouble points
    that you'll find yourself in the outliers mini-project).

    Draws a little scatterplot of the training/testing data

    You fill in the regression code where indicated:
"""    


import sys
import pickle
sys.path.append("../tools/")
from feature_format import featureFormat, targetFeatureSplit
dictionary = pickle.load( open("../final_project/final_project_dataset_modified.pkl", "r") )

### list the features you want to look at--first item in the 
### list will be the "target" feature
features_list = ["bonus", "salary"]
data = featureFormat( dictionary, features_list, remove_any_zeroes=True)
target, features = targetFeatureSplit( data )

### training-testing split needed in regression, just like classification
from sklearn.cross_validation import train_test_split
feature_train, feature_test, target_train, target_test = train_test_split(features, target, test_size=0.5, random_state=42)
train_color = "b"
test_color = "r"



from sklearn import linear_model
reg = linear_model.LinearRegression()
reg.fit (feature_train, target_train)
slope = reg.coef_[0]
intercept = reg.intercept_
print 'slope: ' ,slope, 'intercept: ',  intercept

test_score = reg.score(feature_test, target_test)
print 'score:', test_score
#### interpreted by sklearn as such (e.g. [[27]]).
#km_net_worth = reg.predict([[27]])[0][0]


#plt.scatter(ages,net_worths)
#plt.plot(ages, reg.predict(ages), color='blue', linewidth=3)
#plt.xlabel("ages")
#plt.ylabel("net worths")
#plt.show()

# We have a better score (-0.59 vs -1.48)when using long-term incentive to predict \
# someone's bonus, which translates to a better fit.



### draw the scatterplot, with color-coded training and testing points
import matplotlib.pyplot as plt
for feature, target in zip(feature_test, target_test):
    plt.scatter( feature, target, color=test_color ) 
for feature, target in zip(feature_train, target_train):
    plt.scatter( feature, target, color=train_color ) 

### labels for the legend
plt.scatter(feature_test[0], target_test[0], color=test_color, label="test")
plt.scatter(feature_test[0], target_test[0], color=train_color, label="train")




### draw the regression line, once it's coded
try:
    plt.plot( feature_test, reg.predict(feature_test) )
except NameError:
    pass

reg.fit(feature_test, target_test)
print reg.coef_[0]
plt.plot(feature_train, reg.predict(feature_train), color="b") 

plt.xlabel(features_list[1])
plt.ylabel(features_list[0])
plt.legend()
plt.show()
