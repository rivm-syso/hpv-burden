library(ggplot2)

# Plot cancer incidence 1989-2022, cervix only, sep. age-groups
site <- CE
sex <- 2
op <- par(family = "sans", font = 2, font.lab = 2, font.axis = 2, font.main = 1)
matplot(c(1988 + (1:N_YEARS)), inc[sex, 8, 1:N_YEARS, site],
  type = "o", pch = 19, col = "steelblue", xlim = c(1989, 2022),
  ylim = c(0, max(inc[sex, , , site]) * 1.25), xlab = "Year", ylab = "Number cervical cancer registrations"
)
lines(c(1988 + (1:N_YEARS)), inc[sex, 17, 1:N_YEARS, site], type = "o", pch = 19, col = 1)
lines(c(1988 + (1:N_YEARS)), inc[sex, 15, 1:N_YEARS, site], type = "o", pch = 19, col = 2)
lines(c(1988 + (1:N_YEARS)), inc[sex, 13, 1:N_YEARS, site], type = "o", pch = 19, col = 3)
lines(c(1988 + (1:N_YEARS)), inc[sex, 11, 1:N_YEARS, site], type = "o", pch = 19, col = 5)
lines(c(1988 + (1:N_YEARS)), inc[sex, 9, 1:N_YEARS, site], type = "o", pch = 19, col = 8)
lines(c(1988 + (1:N_YEARS)), inc[sex, 7, 1:N_YEARS, site], type = "o", pch = 19, col = "orange") # steep climb from 2016! Better surveillance??
legend("topleft",
  legend = c("80-84 yrs", "70-74 yrs", "60-64 yrs", "50-54 yrs", "40-44 yrs", "35-39 yrs", "30-34 yrs"),
  col = c(1, 2, 3, 5, 8, "steelblue", "orange"), pch = 19, lwd = 2, cex = 0.75
)
par(op)

# the same plot as above but then using ggplot and incidence tibble
# all age groups between 30-84, in ten year age groups
incidence_data |>
  filter(
    cancer_site == "Baarmoederhalskanker", sex == "F",
    age_group %in% paste0(
      seq(30, 80, 5),
      "-",
      seq(34, 84, 5)
    )
  ) |>
  mutate(age_group = age_group |> as.factor()) |>
  # collapse age groups into 10-year age groups
  mutate(age_group = forcats::fct_collapse(age_group,
    "30-39" = c("30-34", "35-39"),
    "40-49" = c("40-44", "45-49"),
    "50-59" = c("50-54", "55-59"),
    "60-69" = c("60-64", "65-69"),
    "70-79" = c("70-74", "75-79"),
    "80+" = c("80-84", "85+")
  )) |>
  ggplot(aes(x = year, y = number, col = age_group)) +
  geom_line() +
  geom_point() +
  labs(title = "Incidence per year, NKR numbers") +
  theme_minimal()
