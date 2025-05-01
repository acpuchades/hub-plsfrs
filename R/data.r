library(readxl)
library(broom)
library(dplyr)
library(tidyr)
library(stringr)

library(ggplot2)
library(patchwork)

theme_set(theme_grey() + theme(plot.background = element_blank()))

data <- bind_rows(
    read_excel("data/ELP2.xlsx", sheet = "RaterAtrial1") |>
        mutate(
            rater = factor("A", levels = c("A", "B")),
            trial = factor(1, levels = 1:2),
        ),
    read_excel("data/ELP2.xlsx", sheet = "RaterBtrial1") |>
        mutate(
            rater = factor("B", levels = c("A", "B")),
            trial = factor(1, levels = 1:2),
        ),
    read_excel("data/ELP2.xlsx", sheet = "RaterAtrial2") |>
        mutate(
            rater = factor("A", levels = c("A", "B")),
            trial = factor(2, levels = 1:2),
        ),
    read_excel("data/ELP2.xlsx", sheet = "RaterBtrial2") |>
        mutate(
            rater = factor("B", levels = c("A", "B")),
            trial = factor(2, levels = 1:2),
        )
) |>
    rename_with(~ str_to_lower(.x)) |>
    mutate(
        bulbar = habla + salivación + deglución,
        fine_motor = escritura + utensilios + vestido,
        gross_motor = giro + caminar + escaleras,
        respiratory = disnea + ortopnea + ventilación,
    ) |>
    rename(total_plsfrs = total)

data.l <- data |>
    select(id, rater, trial, bulbar, fine_motor, gross_motor, respiratory, total_plsfrs) |>
    pivot_longer(-c(id, rater, trial), names_to = "measure") |>
    mutate(measure = factor(measure, levels = c(
        "bulbar", "fine_motor", "gross_motor", "respiratory", "total_plsfrs"
    )))

data.inter <- data.l |>
    pivot_wider(names_from = rater, values_from = value) |>
    mutate(
        mean_diff = mean(A - B),
        sd_diff = sd(A - B),
        .by = measure
    )

data.intra <- data.l |>
    pivot_wider(names_from = trial, values_from = value) |>
    mutate(
        mean_diff = mean(`1` - `2`),
        sd_diff = sd(`1` - `2`),
        .by = measure
    )
