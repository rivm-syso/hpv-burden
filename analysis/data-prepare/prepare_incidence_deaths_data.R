### read data

incidence_data <-
  readr::read_csv(fs::path(DATA_DIR, DATA_PROCESSED, YEAR_CALCULATION, "incidence.csv")) |> 
  filter(year %in% YEAR_START:YEAR_CALCULATION)

deaths_data <- 
  readr::read_csv(fs::path(DATA_DIR, DATA_PROCESSED, YEAR_CALCULATION, "deaths.csv")) |> 
  filter(year %in% YEAR_START:(YEAR_CALCULATION-1))


### prepare arrays

inc <- array(0, dim = c(N_SEX, N_AGE_GROUPS, N_YEARS, N_SITES)) 
# deaths are only available for N_YEARS-1
dths <- array(0, dim = c(N_SEX, N_AGE_GROUPS, N_YEARS, N_SITES)) 

### populate arrays

# cancer data
for (.x in c("M", "F")) {
  for (.y in CANCER_SITES |> filter(order_site != 9) |> pull(cancer_site)) {
    # get index for sex and cancer site from names 
    id_sex <- if_else(.x == "M", 1, 2)
    id_site <- CANCER_SITES |>
      filter(cancer_site == .y) |>
      pull(order_site)
    # populate arrays
    inc[id_sex, , , id_site] <- convert_cancer_data(incidence_data, .x, .y, number)
    dths[id_sex, , 1:(N_YEARS - 1), id_site] <- convert_cancer_data(deaths_data, .x, .y, number)
  }
}
