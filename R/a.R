library(quantmod)
nikkei <- getSymbols(Symbols = "^N225", 
                     src = "yahoo",
                     from = "2015-01-01",
                     to = "2024-12-31",
                     auto.assign = FALSE)
head(nikkei)
nikkei_cl <- Cl(nikkei)
summary(nikkei_cl)
nikkei_cl <- na.omit(nikkei_cl)
summary(nikkei_cl)
plot(nikkei_cl)
acf(nikkei_cl,main = "")
acf(nikkei_cl, plot = FALSE)


#
library(dygraphs)
dygraph(nikkei_cl, main = "Nikkei 225 Closing Prices") |>
  dyOptions(colors = "steelblue") |>
  dyRangeSelector()

#
library(timsac)


y <- nikkei_cl

for (m1 in 1:3) {
  for (m2 in 1:7) {
    k <- 0
    
    fit <- try(
      decomp(
        y,
        trend.order    = m1,
        ar.order       = m2,
        seasonal.order = k,
        plot           = FALSE
      ),
      silent = TRUE
    )
    
    if (inherits(fit, "try-error")) {
      cat("[ERROR]",
          "trend.order =", m1,
          "ar.order =", m2,
          "seasonal.order =", k,
          "AIC = NA\n")
    } else {
      cat("trend.order =", m1,
          "ar.order =", m2,
          "seasonal.order =", k,
          "AIC =", fit$aic, "\n")
    }
  }
}
library(timsac)
dp <- decomp(nikkei_cl, trend.order = 1, ar.order = 6, seasonal.order = 0)
dp$aic
dp$trend

#

library(tibble)
library(tsibble)
library(forecast)
library(tidyverse)
library(fable)
library(feasts)

nikkei_ts <- tibble(
  date  = as.Date(time(nikkei_cl)),       
  close = as.numeric(nikkei_cl)         
) |> 
  as_tsibble(index = date)

nikkei_ts

lambda <- BoxCox.lambda(nikkei_ts$close)
lambda


nikkei_ts_idx <- nikkei_ts |>
  mutate(t = row_number()) |>
  as_tsibble(index = t)

nikkei_ts_idx <- nikkei_ts_idx |>
  mutate(close_bc = box_cox(close, lambda))


model <- nikkei_ts_idx |>
  model(auto = ARIMA(close))


model_bc <- nikkei_ts_idx |>
  model(auto = ARIMA(close_bc))

report(model)
report(model_bc)

model_bc |>
  gg_tsresiduals()　


model_bc |>
  augment() |>
  filter(.model == "auto") |>
  features(.innov, ljung_box, lag = 10, dof = 3)

model_bc |>
  forecast(h = 250) |>
  filter(.model == "auto") |>
  autoplot(nikkei_ts_idx) +
  labs(
    title = "One-year Forecast of Nikkei 225",
    y = "Nikkei 225 (level scale)",
    level = "Prediction interval"
  )
