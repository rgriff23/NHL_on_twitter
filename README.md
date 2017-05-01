# NHL_on_twitter 

Step-by-step guide to the data collection/analysis presented in [this blog post](https://rgriff23.github.io/2017/05/01/USWNT-NHL-Twitter-popularity.html). 

Note that there is a gap between the GET DATA and ANALYZE DATA sections below, where I had to do some manual cleaning of the data, so my process isn't fully reproducible.

### TWITTER AUTHENTICATION

I am not going over this- if you have not done this yet, follow the steps [here](http://thinktostart.com/twitter-authentification-with-r/). 

```
# load packages
library("twitteR")

# enter your own consumer key/secret and access token/secret
options(httr_oauth_cache=T)
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
```

### GET DATA

One way to get data for a bunch of Twitter accounts is to pull the usernames from a [Twitter list](https://support.twitter.com/articles/76460#). The NHL already has a Twitter list for [NHL players](https://twitter.com/nhl/lists/nhl-players?lang=en), although the list contains some retired players and even non-players. For the US Women's National Team, I made [my own list](https://twitter.com/HeesooRandi/lists/uswnt). Using these lists, we can get a vector of Twitter handles and get data on all of the users. 

```
# load packages
library(httr)
library(rjson)

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
nhl.names <- sapply(nhl.response.list$users, function(i) i$name)
nhl.screennames <- sapply(nhl.response.list$users, function(i) i$screen_name)
```

Using these lists, we can get a vector of Twitter handles and get data on all of the users. 

```
# get USWNT follower stats
uswnt.data <- lookupUsers(uswnt.screennames)
uswnt.followers <- sapply(uswnt.data, function(i) i$followersCount)

# get NHL follower stats
nhl.data <- lookupUsers(nhl.screennames)
nhl.followers <- sapply(nhl.data, function(i) i$followersCount)
```

Next, use `rvest` to grab this table of [2016-2017 NHL salary data](http://www.hockey-reference.com/friv/current_nhl_salaries.cgi) from Hockey-Reference.com.

```
# load packages
install.packages("rvest")
library("rvest")

# get salaries from www.hockey-reference.com 
nhl_salaries <- read_html("http://www.hockey-reference.com/friv/current_nhl_salaries.cgi")
nhl_salaries <- data.frame(html_table(html_node(nhl_salaries, 'table')))

# get rid of commas in numbers and convert to numeric
nhl_salaries$Salary <- as.numeric(gsub("," ,"", nhl_salaries))
```

I had to go through the Twitter list of NHL players manually to clean up names (e.g., nicknames, foreign names) and remove anyone who wasn't a current NHL player in 2016-2017. The file `missing_users` in the `data` folder shows my notes, where I gave some users new names and other users were marked as non-players. After doing this, I merged the NHL Twitter and salary data into a single dataframe, `nhl_clean.csv`, using code in the file `combine_nhl_data.R`. The final cleaned dataframes for the NHL and USWNT players are in the `data` folder. 

### ANALYZE DATA

Import the cleaned dataframes:

```
# load packages
library(data.table)

# read clean data from GitHub
nhl.data <-  fread('https://raw.githubusercontent.com/rgriff23/NHL_on_twitter/master/data/nhl_clean.csv')
uswnt.data <-  fread('https://raw.githubusercontent.com/rgriff23/NHL_on_twitter/master/data/uswnt_clean.csv')

# log transformed follower counts
nhl.data$log.Followers <- log(nhl.data$Followers)
uswnt.data$log.Followers <- log(uswnt.data$Followers)
```

Histogram showing the distribution of Twitter followers for NHL players (gray bars) and USWNT players (red vertical lines):

```
hist(nhl.data$log.Followers, breaks=40, col="gray", xlim=c(4,16), xlab="Log (Number of Followers)", main="")
abline(v=uswnt.data$log.Followers, col="red")
abline(v=mean(nhl.data$log.Followers), col="blue", lwd=3)
```

Fit sigmoidal curve to NHL Salary vs. Followers data and plot:

```
# fit sigmoidal curve
fit <- nls(Salary/1000000 ~ SSlogis(log.Followers, Asym, xmid, scal), data=nhl.data)
x <- seq(4, 16, 0.1)
y <- predict(fit, list(log.Followers=x))

# plot
plot(Salary/1e+06 ~ log.Followers, data=nhl.data, ylab="Salary (in millions of dollars)", xlab="Log (Number of Followers)")
lines(x, y)
abline(v=uswnt.data[uswnt.data$Player=="Hilary Knight","log.Followers"], col="red", lwd=2)
```

Estimate salaries for NHL players with the same popularity as USWNT players:

```
# use model to make salary preditions for USWNT
predictions <- predict(fit, list(log.Followers=uswnt.data$log.Followers))
uswnt.data$Estimated_NHL_salary <- paste("$", round(predictions*1000000,0), sep="")
```
 
### END