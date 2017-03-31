
# twitter authentication
source('~/Dropbox/Code/R/twitter_setup.R', chdir = TRUE)

###################
# GET PLAYER IDS #
#################

# get USWNT players
uswnt.twlist <- "USWNT"
uswnt.twowner <- "HeesooRandi"
uswnt.api.url <- paste0("https://api.twitter.com/1.1/lists/members.json?slug=",
                        uswnt.twlist, "&owner_screen_name=", uswnt.twowner, "&count=500")
uswnt.response <- GET(uswnt.api.url, config(token=twitteR:::get_oauth_sig()))
uswnt.response.list <- fromJSON(content(uswnt.response, as = "text", encoding = "UTF-8"))
uswnt.names <- sapply(uswnt.response.list$users, function(i) i$name)
uswnt.screennames <- sapply(uswnt.response.list$users, function(i) i$screen_name)

# get NHL players
nhl.twlist <- "nhl-players"
nhl.twowner <- "NHL"
nhl.api.url <- paste0("https://api.twitter.com/1.1/lists/members.json?slug=",
                  nhl.twlist, "&owner_screen_name=", nhl.twowner, "&count=500")
nhl.response <- GET(nhl.api.url, config(token=twitteR:::get_oauth_sig()))
nhl.response.list <- fromJSON(content(nhl.response, as = "text", encoding = "UTF-8"))
nhl.description <- sapply(nhl.response.list$users, function(i) i$description)
nhl.names <- sapply(nhl.response.list$users, function(i) i$name)
nhl.screennames <- sapply(nhl.response.list$users, function(i) i$screen_name)

##############################
# GET PLAYER FOLLOWER STATS #
############################

# get USWNT follower stats
uswnt.data <- lookupUsers(uswnt.screennames)
uswnt.followers <- sapply(uswnt.data, function(i) i$followersCount)

# get NHL follower stats
nhl.data <- lookupUsers(nhl.screennames)
nhl.followers <- sapply(nhl.data, function(i) i$followersCount)

# identify as many NHL teams as possible using descriptions

# manually fill in blanks for NHL teams

######################
# VISUALIZE RESULTS #
####################

# histogram with top USWNT players depicted
layout(matrix(1:2,1,2))
hist(nhl.followers/1000, breaks=100, col="gray", main="NHL", xlab="Number of Followers (thousands)")
hist(uswnt.followers/1000, breaks=10, col="gray", main="USWNT", ylab="", xlab="Number of Followers (thousands)")

# log histogram with top USWNT players depicted
hist(log(nhl.followers), 
     breaks=100, 
     col="gray", 
     xlim=log(c(min(uswnt.followers), max(nhl.followers))),
     xlab="Log (Number of Followers)",
     main="")
abline(v=log(uswnt.followers), col="red")
abline(v=mean(log(nhl.followers)), col="blue", lwd=3)

########
# END #
######


