hist(log(nhl.data$Followers), 
     breaks=50, 
     col="gray", 
     xlim=log(c(min(uswnt.data$Followers), max(nhl.data$Followers))),
     xlab="Log (Number of Followers)",
     main="")
abline(v=log(uswnt.data$Followers), col="red")
abline(v=mean(log(nhl.data$Followers)), col="blue", lwd=3)