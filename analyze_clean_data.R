##############
# LOAD DATA #
############

# load packages
library(RCurl)

# read data 
nhl.url <- "https://raw.githubusercontent.com/rgriff23/NHL_on_twitter/master/data/nhl_followers_salaries_clean.csv"
uswnt.url <- "https://raw.githubusercontent.com/rgriff23/NHL_on_twitter/master/data/uswnt_follower_counts.csv"
nhl.data <- read.csv(text=getURL(nhl.url), header=T)
uswnt.data <- read.csv(text=getURL(uswnt.url), header=T)

# log transformed follower counts
nhl.data$log.Followers <- log(nhl.data$Followers)
uswnt.data$log.Followers <- log(uswnt.data$Followers)

##############
# HISTOGRAM #
############

hist(nhl.data$log.Followers, 
     breaks=50, 
     col="gray", 
     xlim=c(4,16),
     xlab="Log (Number of Followers)",
     main="")
abline(v=uswnt.data$log.Followers, col="red")
abline(v=mean(nhl.data$log.Followers), col="blue", lwd=3)

####################################
# SIGMOIDAL MODAL AND SCATTERPLOT #
##################################

# fit sigmoidal curve
fit <- nls(Salary/1000000 ~ SSlogis(log.Followers, Asym, xmid, scal), data = nhl.data)
x = seq(4,16,0.1)
y=predict(fit, list(log.Followers=x))
plot(Salary/1e+06 ~ log.Followers, data = nhl.data, 
     ylab="Salary (in millions of dollars)",
     xlab="Log (Number of Followers)")
lines(x,y)

#######################
# SALARY PREDICTIONS #
#####################

# use model to make salary preditions for USWNT
uswnt.data$log.Followers <- log(uswnt.data$Followers)
predictions <- predict(fit, list(log.Followers=uswnt.data$log.Followers))
uswnt.data$Prediction <- predictions*1000000
uswnt.data$Estimated_NHL_salary <- paste("$", round(predictions*1000000,0), sep="")

# sort USWNT data
uswnt.data[sort.int(uswnt.data$Prediction, index.return=T, decreasing=T)$ix,][1:14,-c(2,4,5)]

########
# END #
######