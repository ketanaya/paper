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
plot(nikkei_cl, main = NULL)
help("plot")
acf(nikkei_cl,main = "")
acf(nikkei_cl, plot = FALSE)
help("summary")

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

nikkei_ts_idx <- nikkei_ts |>
  mutate(t = row_number()) |>
  as_tsibble(index = t)

model <- nikkei_ts_idx |>
  model(auto = ARIMA(close))


report(model)

#normal
model |>
  gg_tsresiduals()　


model |>
  augment() |>
  filter(.model == "auto") |>
  features(.innov, ljung_box, lag = 25, dof = 3)

model |>
  forecast(h = 250) |>
  filter(.model == "auto") |>
  autoplot(nikkei_ts_idx) +
  theme_minimal(base_family = "HiraginoSans-W3") +
  labs(
    x = "日付",
    y = "終\n値",
    level = "Prediction interval"
       ) + 
  theme(
    axis.title.y = element_text(angle = 0, vjust = 0.5),
    plot.background = element_rect(fill = "white", color = NA)
  )

help(features)

nikkei_ts |> 
  fill_gaps() |>          
  gg_season(y = close, period = "year")