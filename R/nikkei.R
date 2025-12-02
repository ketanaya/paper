#データの下調べ
library(quantmod)
nikkei <- getSymbols(Symbols = "^N225", 
                 src = "yahoo",
                 from = "2015-01-01",
                 to = "2024-12-31",
                 auto.assign = FALSE)

head(nikkei)
class(nikkei)
summary(nikkei)

nikkei_cl <- Cl(nikkei)
na <- nikkei_cl[is.na(nikkei_cl)]
na


install.packages("timsac")
library(timsac)
ls(2)
decomp(nikkei_cl)

summary(nikkei_cl)
length(nikkei_cl)
nikkei_cl <- na.omit(nikkei_cl)

# CloseとAdjustedを取り出す
close_vals <- Cl(nikkei)
adj_vals   <- Ad(nikkei)

# 差を調べる（TRUE/FALSE）
diff_flag <- close_vals != adj_vals

# 不一致の行数を数える
sum(diff_flag, na.rm = TRUE)


#横軸時間のプロット
plot(nikkei_cl)


#ヒストグラムと５数要約
hist(nikkei_cl)
summary(nikkei_cl)


#自己相関係数
acf(nikkei_cl) 


#ADF検定
library(urca)
trend <- ur.df(nikkei_cl, type = "trend",selectlags = "AIC")
summary(trend)

drift <- ur.df(nikkei_cl, type = "drift",selectlags = "AIC")
summary(drift)

none <- ur.df(nikkei_cl, type = "none",selectlags = "AIC")
summary(none)

nikkei_cl_diff <- diff(nikkei_cl, differences = 1)
summary(nikkei_cl_diff)
nikkei_cl_diff <- na.omit(nikkei_cl_diff)
none_diff <- ur.df(nikkei_cl_diff, type = "none",selectlags = "AIC")
summary(none_diff)


#ARIMA
library(forecast)
model <- auto.arima(nikkei_cl, d = 1, ic = "aicc", stepwise = FALSE)
summary(model)

checkresiduals(model)

library(ggplot2)
fc <- forecast(model, h = 60)
plot(fc, include = 252) 
acf(nikkei_cl_diff)
