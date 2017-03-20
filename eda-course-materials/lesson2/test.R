getwd()
setwd('C:/Users/jkudinovich/Desktop/UDACITY/DAND/eda-course-materials/lesson2')
getwd()
statesInfo <-read.csv('stateData.csv')

stateSubset <- subset(statesInfo, state.region==1)
head(stateSubset,2)
dim(stateSubset)

stateSubsetBracket <- statesInfo[statesInfo$state.region==1, ]


reddit <-read.csv('reddit.csv')
table(reddit$employment.status)

str(reddit)

levels(reddit$age.range)

library(ggplot2) 
qplot(data=reddit, x=age.range)

#setting levels of ordered factors
reddit$age.range <-ordered(reddit$age.range, levels = c('Under 18', '18-24', '25-34', '35-44', '45-54', '55-64',
                           '65 0r Above'))

# OR
reddit$age.range <-factor(reddit$age.range, levels = c('Under 18', '18-24', '25-34', '35-44', '45-54', '55-64',
                                                        '65 0r Above'), ordered= T)

