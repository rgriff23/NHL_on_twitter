################
# IMPORT DATA #
##############

# read data
nhl.followers <- read.csv("~/Desktop/GitHub/NHL_on_twitter/data/nhl_follower_counts.csv", header=T, stringsAsFactors=F)
nhl.salaries <- read.csv("~/Desktop/GitHub/NHL_on_twitter/data/nhl_salaries.csv", header=T, stringsAsFactors=F)

############################
# CLEAN TWITTER NAME DATA #
##########################

# identify missing users
#missing.users <- nhl.followers[!nhl.followers$Player %in% nhl.salaries$Player,]
#nrow(missing.users) # 228 (260 had matches)

# export data on Twitter names that aren't in salary database
#write.csv(missing.users, file="~/Desktop/GitHub/NHL_on_twitter/data/missing_users.csv", row.names=F)

missing.users <- read.csv("~/Desktop/GitHub/NHL_on_twitter/data/missing_users.csv", header=T, stringsAsFactors=F)

################
# MERGE FILES #
##############

# drop Twitter users with Rename=NA in missing.users
drop <- missing.users[is.na(missing.users$Rename), "Handle"]
nhl.followers.clean <- nhl.followers[!nhl.followers$Handle%in%drop,]

# replace names of Twitter users in missing.users with Rename
for (i in 1:nrow(nhl.followers.clean)) {
  n <- nhl.followers.clean[i,"Handle"]
  if (n %in% missing.users$Handle) {
    nhl.followers.clean[i,"Player"] <- missing.users[which(missing.users$Handle == n),"Rename"]
  }
}

# check that every Twitter user has a match in nhl.salaries
nrow(nhl.followers.clean) 
sum(nhl.followers.clean$Player %in% nhl.salaries$Player)

# merge files
new.cols <- nhl.salaries[match(nhl.followers.clean$Player, nhl.salaries$Player),c("Tm","Salary")]
nhl.followers.salaries.clean <- data.frame(nhl.followers.clean, new.cols)
names(nhl.followers.salaries.clean)[4] <- "Team"

# drop player with no data on salary
nhl.followers.salaries.clean <- nhl.followers.salaries.clean[!is.na(nhl.followers.salaries.clean$Salary),]

# write data
write.csv(nhl.followers.salaries.clean, file="~/Desktop/GitHub/NHL_on_twitter/data/nhl_followers_salaries_clean.csv", row.names=F)

##############
# VISUALIZE #
############

# uswnt data
uswnt.followers <- read.csv("~/Desktop/GitHub/NHL_on_twitter/data/uswnt_follower_counts.csv", header=T, stringsAsFactors=F)

# linear model of salary vs log(followers)
mod <- lm(Salary/1000000~log(Followers), data=nhl.followers.salaries.clean)

# scatterplot of followers vs salary
plot(Salary/1000000~log(Followers), data=nhl.followers.salaries.clean, ylab="Salary (in millions of dollars)")
abline(mod)
abline(v=log(68000), col="red")

# use model to make salary preditions for USWNT
predictions <- predict(mod, uswnt.followers)
uswnt.followers$PredictedSalary <- predictions*1000000

# average salary for NHL players with 50-70K followers
fol60to70 <- nhl.followers.salaries.clean$Followers > 50000 & nhl.followers.salaries.clean$Followers < 70000
mean(nhl.followers.salaries.clean[fol60to70,"Salary"]) # $2.8 million

# average salary for NHL players with 10-35K followers
fol15to35 <- nhl.followers.salaries.clean$Followers > 15000 & nhl.followers.salaries.clean$Followers < 35000
mean(nhl.followers.salaries.clean[fol15to35,"Salary"]) # $2.7 million

########
# END #
######