# packages
install.packages("rvest")
library("rvest")

# get salaries from www.hockey-reference.com 
salaries <- read_html("http://www.hockey-reference.com/friv/current_nhl_salaries.cgi")
salaries <- data.frame(html_table(html_node(salaries, 'table')))

# get rid of commas in numbers and convert to numeric
salaries$Salary <- as.numeric(gsub(",","",salaries$Salary))

# export table
write.csv(salaries, file="~/Desktop/GitHub/NHL_on_twitter/data/nhl_salaries.csv", row.names=F)
