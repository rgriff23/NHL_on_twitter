# fit sigmoidal curve
fit <- nls(Salary/1000000 ~ SSlogis(log.Followers, Asym, xmid, scal), data = nhl.followers.salaries.clean)x = seq(7,15,0.1)
y=predict(fit, list(log.Followers=x))
plot(Salary/1e+06 ~ log.Followers, data = nhl.followers.salaries.clean)
lines(x,y)