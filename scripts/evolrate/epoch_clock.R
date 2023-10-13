setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library(tidyverse)
library(data.table)
logger <- fread("Coelacanths_87_268_tipsVariance_Dis_Mer_epoch_all.log")


df <- logger |>
  select(contains("clock")) |> #select the clock rate parameters
  gather(key = Period, value = rate) # convert into long table with 2 columns

df$Clock <- gsub("\\..*", "", df$Period)
df$Period <- gsub("[a-z]+(.clock.)", "", df$Period, perl = TRUE)
df$Period <- gsub(".relRate", "", df$Period)

df <- df |>
  filter(!(rate > 3 & Clock == "meristic"))
df <- mutate(df, Period=factor(Period, levels=unique(df$Period)),
             Clock=factor(Clock, levels=c("discrete", "continuous", "meristic")))
period_cols <- c("#cb8c37", "#67a599", "#f04028", "#812b92", "#34b2c9", "#7fc64e", "#fd9a52")

p <- ggplot(df, aes(x=Period, y=rate, fill=Period, color=Period)) +
  geom_violin(width=1.2) +
  theme_light() +
  scale_fill_manual(values=period_cols) +
  scale_color_manual(values=period_cols) +
  facet_wrap(~Clock, scales="free", dir="v") +
  stat_summary(fun = "mean",
               geom = "point",
               color = "black",
               fatten=1.5) +
  theme(legend.position = "none") +
  theme(strip.text = element_text(color = "black")) +
  theme(strip.background = element_rect(fill = "#e2e2e2"))

p
ggsave("epoch_clock.pdf", p, height=9, width=6)

