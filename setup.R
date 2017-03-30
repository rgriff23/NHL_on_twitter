
#################
# PREPARATIONS #
###############

# load packages
if (!require("twitteR")) {install.packages("twitteR")}
library("twitteR")
library("rjson")
library("httr")

# setting up Twitter authentication (application: HangukMiguk2017)
consumer_key <- "WEEW6k4YAhu071DaNSU4H06gI"
consumer_secret <- "4Pg0CW5wscKDvydmGinxSvAJkcV1RzaAffysMfM0KLS5FP7RgF"
access_token <- "842737418142801920-4EAyDRuvJkm49EaN4Jeg19gUGubhegu"
access_secret <- "IPT8dknS7AyxqDv70BjjAoOOLZX61MKgX6dtpHwp9cxs4"
options(httr_oauth_cache=T)
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

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
nhl.names <- sapply(nhl.response.list$users, function(i) i$name)
nhl.screennames <- sapply(nhl.response.list$users, function(i) i$screen_name)

##############################
# GET PLAYER FOLLOWER STATS #
############################

# get USWNT follower stats

# get NHL follower stats

######################
# VISUALIZE RESULTS #
####################

# histogram with top USWNT players depicted

########
# END #
######


