
# twitter authentication
source('~/Dropbox/Code/R/twitter_setup.R', chdir = TRUE)

################################################
# GET PLAYER IDS FROM PUBLISHED TWITTER LISTS #
##############################################

# get USWNT players
uswnt.api.url <- paste0("https://api.twitter.com/1.1/lists/members.json?slug=",
                        "USWNT", "&owner_screen_name=", "HeesooRandi", "&count=500")
uswnt.response <- GET(uswnt.api.url, config(token=twitteR:::get_oauth_sig()))
uswnt.response.list <- fromJSON(content(uswnt.response, as = "text", encoding = "UTF-8"))
uswnt.names <- sapply(uswnt.response.list$users, function(i) i$name)
uswnt.screennames <- sapply(uswnt.response.list$users, function(i) i$screen_name)

# get NHL players
nhl.api.url <- paste0("https://api.twitter.com/1.1/lists/members.json?slug=",
                  "nhl-players", "&owner_screen_name=", "NHL", "&count=500")
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

###############
# WRITE DATA #
#############

# USWNT
uswnt.data <- data.frame(Player=uswnt.names, Handle=uswnt.screennames, Followers=uswnt.followers)
write.csv(uswnt.data, file="~/Desktop/GitHub/NHL_on_twitter/data/uswnt_follower_counts.csv", row.names=F)

# NHL
nhl.data <- data.frame(Player=nhl.names, Handle=nhl.screennames, Followers=nhl.followers)
write.csv(nhl.data, file="~/Desktop/GitHub/NHL_on_twitter/data/nhl_follower_counts.csv", row.names=F)

########
# END #
######