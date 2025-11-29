library(arrow)
x <-read_parquet("/Users/masa/Documents/update/Project/DoubleLogModelingSkewError/0DataSet/firmfinC2019.parquet")
dim(x)
fname <- unique(x$firmID)

library(dplyr)
library(ggplot2)
y <- x %>% filter(year == 2017) %>% select(firm, sales, assets_total)
y <- na.omit(y)
y
set.seed(12345)
y <- sample_n(y, 10)
y
write.csv(y[,2:3],"tmp.csv")

