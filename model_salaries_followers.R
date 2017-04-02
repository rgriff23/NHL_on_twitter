# fit sigmoidal curve
fit <- nls(Salary/1000000 ~ SSlogis(log.Followers, Asym, xmid, scal), data = nhl.followers.salaries.clean)x = seq(7,15,0.1)
y=predict(fit, list(log.Followers=x))
plot(Salary/1e+06 ~ log.Followers, data = nhl.followers.salaries.clean)
lines(x,y)

# use model to make salary preditions for USWNT
uswnt.followers$log.Followers <- log(uswnt.followers$Followers)
predictions <- predict(fit, list(log.Followers=uswnt.followers$log.Followers))
uswnt.followers$PredictedSalary <- predictions*1000000

# sort USWNT data
uswnt.followers[sort.int(uswnt.followers$PredictedSalary, index.return=T, decreasing=T)$ix,]
