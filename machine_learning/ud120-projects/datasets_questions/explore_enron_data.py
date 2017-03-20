#!/usr/bin/python

""" 
    Starter code for exploring the Enron dataset (emails + finances);
    loads up the dataset (pickled dict of dicts).

    The dataset has the form:
    enron_data["LASTNAME FIRSTNAME MIDDLEINITIAL"] = { features_dict }

    {features_dict} is a dictionary of features associated with that person.
    You should explore features_dict as part of the mini-project,
    but here's an example to get you started:

    enron_data["SKILLING JEFFREY K"]["bonus"] = 5600000
    
"""

import pickle

enron_data = pickle.load(open("../final_project/final_project_dataset.pkl", "r"))

#Number of persons in the dataset
num_person=0
for person in enron_data:
    #print person
    num_person+=1

print 'Number of persons in the dataset: ', num_person

#Number of features for each person
num_features=0
for person in enron_data:
    num_features = len(enron_data[person])
#    for feature in enron_data[person]:
#        print feature

    break
    
print 'Number of features for each person: ', num_features

#Number of POIs (persons of interest)
num_poi=0
for person in enron_data:
    if enron_data[person]["poi"]==1:
        num_poi+=1
        
print 'Number of POIs (persons of interest):', num_poi


#Number of POI names in poi_names.txt
count=0
poi_names = open("../final_project/poi_names.txt").read().split('\n')
for line in poi_names:
    if "(n)" in line or "(y)" in line:
        count+=1
       
print 'Number of POI names in poi_names.txt:', count
#Not enough data for analysis, to learn patterns. 
#More data is always better for modeling

#Total value of the stock belonging to James Prentice?
print 'Total value of the stock belonging to James Prentice: ', \
enron_data["PRENTICE JAMES"]['total_stock_value']

#How many email messages do we have from Wesley Colwell to persons of interest?
print 'Number of email messages from Wesley Colwell to persons of interest: ',\
enron_data['COLWELL WESLEY']['from_this_person_to_poi']

#Value of stock options exercised by Jeffrey K Skilling
print 'Value of stock options exercised by Jeffrey K Skilling: ',\
enron_data['SKILLING JEFFREY K']['exercised_stock_options']

print 'Jeffrey Skilling - the CEO of Enron during most of the time that fraud \
was being perpetrated'
print 'Kenneth Lay - chairman of the Enron board of directors'
print 'Andrew Fastow - CFO (chief financial officer) of Enron during most of the time that \
fraud was going on'

print 'Who took home the most money:'
print 'SKILLING JEFFREY K', enron_data["SKILLING JEFFREY K"]['total_payments']
print 'LAY KENNETH L', enron_data["LAY KENNETH L"]['total_payments']
print 'FASTOW ANDREW S', enron_data["FASTOW ANDREW S"]['total_payments']


#How many folks in this dataset have a quantified salary?
salary_count = 0
for person in enron_data:
    if enron_data[person]['salary'] != 'NaN':
        salary_count += 1
print 'How many people in the dataset have a quantified salary', salary_count

#How many folks in this dataset have a known email address
email_count=0
for person in enron_data:
    if enron_data[person]['email_address'] != 'NaN':
        email_count+=1
print 'How many people in the dataset have a known email address', email_count

#A python dictionary can’t be read directly into an sklearn classification or \
#regression algorithm; instead, it needs a numpy array or a list of lists \
#(each element of the list (itself a list) is a data point, and the elements \
# of the smaller list are the features of that point).
#
#Some helper functions (featureFormat() and targetFeatureSplit() in \
#tools/feature_format.py) that can take a list of feature names and the data \
#dictionary, and return a numpy array.
#
#In the case when a feature does not have a value for a particular person,\
# this function will also replace the feature value with 0 (zero).

#How many people in the E+F dataset (as it currently exists) have “NaN” for \
#their total payments? What percentage of people in the dataset as a whole is this?
total_payments_nan_count=0
for person in enron_data:
    if enron_data[person]['total_payments'] == 'NaN':
        total_payments_nan_count+=1
print 'How many people in the dataset have have “NaN” for their total payments'\
, total_payments_nan_count
print 'What percentage of people in the dataset as a whole: ', \
(float(total_payments_nan_count)/num_person)*100


#How many POIs in the E+F dataset have “NaN” for their total payments? \
#What percentage of POI’s as a whole is this?
total_payments_nan_count_poi=0
for person in enron_data:
    if enron_data[person]["poi"]==1 and enron_data[person]['total_payments'] == 'NaN':
        total_payments_nan_count_poi+=1
print 'How many POIs in the dataset have have “NaN” for their total payments'\
, total_payments_nan_count_poi
print 'What percentage POI’s the dataset as a whole: ', \
(float(total_payments_nan_count_poi)/num_poi)*100


