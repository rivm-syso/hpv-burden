### Prepare cin23 data in the form as they are assumed for the calculate.R script
### Note that hardcoded numbers in this script are based on data in Kok et al. 2011

# read data: see data-raw/cin23_data.R for underlying R code
cin23_data <- readr::read_csv(fs::path(DATA_DIR, DATA_RAW, YEAR_DATA, "cin23_data.csv"))

# filter by years included in the calculation
cin23_data <- cin23_data |> 
  filter(year %in% YEAR_START:YEAR_CALCULATION)

# copy data from previous year to current year of calculation
cin23_data <- cin23_data |> 
  bind_rows(cin23_data |> 
              filter(year == YEAR_CALCULATION - 1) |> 
              mutate(year = YEAR_CALCULATION)) 

cin23_vector <- cin23_data |> 
  pull(combined_cin23)

inc_cin23 <- array(0, dim = c(N_AGE_GROUPS, N_YEARS))

idx_2005 <- 2005 - YEAR_START + 1
for (y in 1:(idx_2005 - 1)) { # ie. loop from 1989 t/m 2004 (index=16)
  allocate3059 <- cin23_vector[y] * c(0.322, 0.289, 0.189, 0.111, 0.056, 0.033)
  inc_cin23[, y] <- c(rep(0, 6), round(allocate3059), rep(0, (N_AGE_GROUPS - 12)))
}
for (y in idx_2005:N_YEARS) { # ie. loop from 2005 (index=17) t/m year of calculation
  # Use the *only* data yet found on age distr of CIN-2/3
  allocate3059 <- cin23_vector[y] * c(0.322, 0.289, 0.189, 0.111, 0.056, 0.033) # distr over agegrps, from A. Vink PhD thesis
  inc_cin23[, y] <- c(rep(0, 6), round(allocate3059), rep(0, (N_AGE_GROUPS - 12)))
}

## ACTUALLY ONLY THESE NEEDED FOR JAGS MODEL!
inctot_cin23 <- apply(inc_cin23, 2, sum)
alloc_cin23 <- c(0, 0, 0, 0, 0, 0, 0.322, 0.289, 0.189, 0.111, 0.056, 0.033, 0, 0, 0, 0, 0, 0) # ,0 [when N_AGE_GROUPS was =19 extra zero was added]

