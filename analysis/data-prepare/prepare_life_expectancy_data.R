life_expectancy_data <- readr::read_csv(fs::path(DATA_DIR, DATA_RAW, "life_expectancy.csv"))

lifeExpNL <- life_expectancy_data |> 
  arrange(order_age_group) |> 
  pull(expected) |> 
  matrix(nrow = N_SEX, ncol = N_AGE_GROUPS, byrow = TRUE)