library(quantmod)
library(ggplot2)

# 1. データの取得
nikkei <- getSymbols(Symbols = "^N225", 
                     src = "yahoo", 
                     from = "2015-01-01", 
                     to = "2024-12-31", 
                     auto.assign = FALSE)

# 2. データ整形
nikkei_cl <- Cl(nikkei)
nikkei_cl <- na.omit(nikkei_cl)

df_nikkei <- ggplot2::fortify(nikkei_cl)
class(df_nikkei)
colnames(df_nikkei) <- c("Date", "Price")
head(df_nikkei)
# 3. ggplotで作図
p <- ggplot(data = df_nikkei, aes(x = Date, y = Price)) +
  geom_line() +
  theme_minimal(base_family = "HiraginoSans-W3") + 
  labs(title = NULL,
       x = "日付",
       y = "終\n値") +
  theme(
    axis.title.y = element_text(angle = 0, vjust = 0.5),
    # ▼▼▼ 追加: 背景を白にする設定 ▼▼▼
    plot.background = element_rect(fill = "white", color = NA)
  )

# 画面表示
print(p)

# 4. 保存 (背景は透明のままでOKとのことなので bg指定なし)
ggsave("nikkei_plot.png", plot = p, width = 6, height = 4, dpi = 300)

print("保存完了: nikkei_plot.png")


# 2. PNG保存 (現在の場所に直接保存)
png(filename = "acf_plot_base.png", width = 600, height = 400)

# 3. 作図 (余計なタイトルを消す)
acf(nikkei_cl, main = "")

# 4. 終了
dev.off()


png(filename = "decomp_plot.png", 
    width = 2400, height = 2400, res = 300, pointsize = 20)
par(mar = c(2, 2, 3, 1))
library(timsac)
dp <- decomp(nikkei_cl, trend.order = 1, ar.order = 6, seasonal.order = 0)
dev.off()


# 2. PNG保存 (現在の場所に直接保存)
png(filename = "acf_residual.png", width = 600, height = 400)

# 3. 作図 (余計なタイトルを消す)
model |>
  gg_tsresiduals()　


# 4. 終了
dev.off()

png(filename = "predict_plot.png", width = 600, height = 400)
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
dev.off()

