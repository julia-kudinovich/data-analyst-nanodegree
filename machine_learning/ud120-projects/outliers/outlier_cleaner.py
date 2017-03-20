#!/usr/bin/python


def outlierCleaner(predictions, ages, net_worths):
    """
        Clean away the 10% of points that have the largest
        residual errors (difference between the prediction
        and the actual net worth).

        Return a list of tuples named cleaned_data where 
        each tuple is of the form (age, net_worth, error).
    """
    
    cleaned_data = []

    for age, net, pr in zip(ages, net_worths, predictions):
        cleaned_data.append((age[0], net[0], abs(pr[0]-net[0])))
        cleaned_data.sort(key=lambda x: x[2],reverse=True)
        
    cleaned_data = cleaned_data[int(len(cleaned_data) * 0.1) :]
    return cleaned_data

