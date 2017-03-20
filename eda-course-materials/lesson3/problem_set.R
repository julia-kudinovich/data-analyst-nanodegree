#1)a-b
library(ggplot2) 
data(diamonds) 
summary(diamonds)
#C
str(diamonds)
#D
?diamonds

#2

qplot(x=price,  data=diamonds )


#Diamond Counts
sum(diamonds$price<500)
sum(diamonds$price<250)
sum(diamonds$price>=15000)


#Cheaper Diamonds
qplot(x=price,  data=diamonds, binwidth=500) + 
  scale_x_continuous(limits = c(0,20000), breaks = seq(0,20000, 1000))
# TO save an iamge: ggsave('priceHistogram.png')

#Price By Cut Histograms
qplot(x=price,  data=diamonds, binwidth=500) + 
  scale_x_continuous(limits = c(0,20000), breaks = seq(0,20000, 1000))+ 
  facet_wrap(~cut)

#Price by cut
by(diamonds$price, diamonds$cut, max)
by(diamonds$price, diamonds$cut, min)
by(diamonds$price, diamonds$cut, median)

# Scales And Multiple Histograms
qplot(x = price, data = diamonds) + facet_wrap(~cut, scales="free_y")


#Price Per Carat By Cut
qplot(x = price/carat, data = diamonds, binwidth=0.02) + facet_wrap(~cut, scales="free_y") + scale_x_log10()


#Price Box Plots
qplot(y=price,  x =cut,  data=diamonds, binwidth=500, geom = 'boxplot', fill = color)


#Interquartile Range - IQR
summary(subset(diamonds, color=='D')$price )

summary(subset(diamonds, color=='J')$price )

IQR(subset(diamonds, color=='D')$price)
IQR(subset(diamonds, color=='J')$price)


#Price Per Carat Box Plots By Color
qplot(y=price/carat,  x =color,  data=diamonds, binwidth=500, geom = 'boxplot', fill = color)

by(diamonds$price/diamonds$carat, diamonds$color, summary)

#Carat Frequency Polygon
qplot(x=carat,  data=diamonds,  geom = 'freqpoly', binwidth=0.1) +
  scale_x_continuous(breaks = seq(0,2,0.1), limits = c(0,2))+
  scale_y_continuous(breaks = seq(0,30000,1000))+
  coord_cartesian(ylim = c(0,2000)) +
  geom_hline(yintercept = 2000)

#2)Price Vs. X
ggplot(aes(x=x , y=price), data=diamonds) +
  geom_point() +
  coord_cartesian(xlim = c(0,11))
#Price tends to go up with x. Exponential relationship. some outliers with x =0

# Correlations
cor.test(diamonds$x, diamonds$price)
cor.test(diamonds$y, diamonds$price)
cor.test(diamonds$z, diamonds$price)

#Price Vs. Depth
ggplot(aes(x=depth, y=price), data=diamonds) +
  geom_point(alpha=1/100) + 
  scale_x_continuous(limits = c(43,80), breaks=seq(43,80,2))

#Typical Depth Range : 59 to 64

#Correlation - Price And Depth (= -0.0106474)
cor.test(diamonds$price, diamonds$depth)

#Price Vs. Carat
ggplot(aes(x=carat, y=price), 
       data = subset(diamonds, diamonds$price < quantile(diamonds$price, 0.99) &
                       diamonds$carat < quantile(diamonds$carat, 0.99))) + 
  geom_point()


#Price Vs. Volume (Exponential relationship, couple of extreme outliers, Some volumes are 0)
diamonds$volume <- diamonds$x * diamonds$y * diamonds$z

ggplot(aes(x=volume, y=price), data=diamonds) +
  geom_point()

sum(diamonds$volume == 0)

#Correlations On Subsets
diamnods_limit_volume <- subset(diamonds, volume>0 & volume<800)
cor.test(diamnods_limit_volume$price, diamnods_limit_volume$volume)

#Adjustments - Price Vs. Volume
#A linear model would not be useful in estimating the price of diamonds because the pattern of data 
#doesn't follow a linear line.
# non-linear model might fit better the price estimation but linear model is still good.
#The reason is Pearson's r - a measure of the linear correlation - is 0.92 for the diamond's volumes 
#in range (0,800).

#with(subset(diamonds, diamonds$volume > 0 & diamonds$volume < 800), 
#     cor.test(price, volume,method = 'pearson'))

# linear model doesn't fit the scattered points. The deviations are way bigger 
#even though the correlation value is VERY high.

ggplot(aes(x=volume, y=price),data=diamnods_limit_volume) +
  geom_point(alpha=1/100)+
  geom_smooth(method = 'lm')

#Mean Price By Clarity
diamondsByClarity <- diamonds %>%
  group_by(clarity) %>%
  summarize(mean_price = mean(price),
            median_price = median(price),
            min_price = min(price),
            max_price = max(price),
            n=n())


#Bar Charts Of Mean Price
diamonds_by_clarity <- group_by(diamonds, clarity)
diamonds_mp_by_clarity <- summarise(diamonds_by_clarity, mean_price = mean(price))

diamonds_by_color <- group_by(diamonds, color)
diamonds_mp_by_color <- summarise(diamonds_by_color, mean_price = mean(price))

pd1 <- ggplot(aes(x=clarity,y = mean_price, fill= clarity),data = diamonds_mp_by_clarity ) +
  geom_bar(stat = "identity")
pd2 <- ggplot(aes(x=color,y = mean_price,  fill= color), data = diamonds_mp_by_color ) +
  geom_bar(stat = "identity")

grid.arrange(pd1, pd2, ncol=2)

#SI2 has the best mean price whereas VVS1 has the worst mean price. 
# However there wasn't a very big change in other groups.  Which is odd since SI2 is worse 
#than VVS1. VVS1 is the second to the last. IF is the best clarity
#Mean price for color increase from D to J.  J has the best mean price and D and E has the worst mean price. 
#Which is odd since D is the best color and J is the worst
#Mean price tends to decrease as clarity improves. The same can be said for color.

#Mean prcie acroos cut;

diamonds_by_cut <- group_by(diamonds, cut)
diamonds_mp_by_cut <- summarise(diamonds_by_cut, mean_price = mean(price))
ggplot(aes(x=cut,y = mean_price, fill= cut),data = diamonds_mp_by_cut ) +
  geom_bar(stat = "identity")
# again odd


# Price Histograms With Facet And Color
qplot(x=price, data=diamonds, fill = cut) +
  facet_wrap(~ color) 

# using log(price) for the x-axis to adjust for positive skew in the data
qplot(x=log(price), data=diamonds, fill = cut) +
  facet_wrap(~ color) 

#Price Vs. Table Colored By Cut
ggplot(aes(x=table, y=price), data = diamonds) +
  geom_point(aes(color=cut))

#Price Vs. Volume And Diamond Clarity
ggplot(aes(x=volume, y=log(price)), 
       data = subset(diamonds, diamonds$volume < quantile(diamonds$volume, 0.99) )) +
  geom_point(aes(color=cut))


#Proportion Of Friendships Initiated
pf$prop_initiated = pf$friendships_initiated/pf$friend_count

#Prop_initiated Vs. Tenure
ggplot(aes(x=tenure, y=prop_initiated), data=subset(pf, !is.na(pf$year_joined)))+
  geom_line(aes(color=year_joined.bucket), stat = 'summary', fun.y = median) 

#Smoothing Prop_initiated Vs. Tenure
ggplot(aes(x=tenure, y=prop_initiated), data=subset(pf, !is.na(pf$year_joined)))+
  geom_line(aes(color=year_joined.bucket), stat = 'summary', fun.y = median) +
  geom_smooth()

# Largest Group Mean Prop_initiated
summary(subset(pf, pf$year_joined.bucket=='(2012,2014]' & !is.nan(pf$prop_initiated)))
#or
with(subset(pf, pf$year_joined.bucket == '(2012,2014]' & !is.nan(pf$prop_initiated)), mean(prop_initiated))

#Price/Carat Binned, Faceted, & Colored

#When we have data that falls into categories, scatterplots can be difficult to interpret due 
#to overplotting on the individual levels of that feature. When we jitter the points in the plot
#horizontally, this allows us to better see what the distribution of points are within each level, 
#especially since we have a multivariate plot where we are coloring points by diamond color grade. 
#It's much easier to see how the color grades are distributed when the points are jittered
#Functionally, we should not think of points that are off-center as being any different from points 
#close-to-center in each group. The data should still be interpreted as categorical as before. 
#One thing to keep in mind is that you should have a gap between columns of data so that it is clear 
#to which level each point belongs

ggplot(aes(x=cut, y=price/carat), data=diamonds) +
  geom_jitter(aes(color=color)) +
  facet_wrap(~clarity)
