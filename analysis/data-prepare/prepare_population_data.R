# read data
population_data <-
  readr::read_csv(fs::path(DATA_DIR, DATA_PROCESSED, YEAR_CALCULATION, "population.csv")) |>
  filter(year %in% YEAR_START:YEAR_CALCULATION)

# prepare array
populNL <- array(0, dim = c(N_SEX, N_AGE_GROUPS, N_YEARS))

## populate array
# population data
populNL[1, , ] <- convert_population_data(population_data, "M")
populNL[2, , ] <- convert_population_data(population_data, "F")
