#ナイル川
df <- Nile
plot(df)

#ts作ってみる
library(timeSeriesDataSets)
library(tidyverse)
df <- AirPassengers_ts   
class(df)  
plot(df)
df <- window(df, end = c(1959, 12))
df

#tsの統合
df1 <- Nile
df2 <- ts(Nile, start = 1866)
df1
df2
ts.union(df1, df2)
df2 <- 2*df1
df2
ts.plot(cbind(df1, df2), lty = c("solid", "dashed"))

#
library(quantmod)
getSymbols("^N225", from = "2024-01-01", to = "2024-12-31")
class(N225)
