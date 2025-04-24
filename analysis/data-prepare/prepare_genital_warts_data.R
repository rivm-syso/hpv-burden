genital_warts_data <- readr::read_csv(fs::path(DATA_DIR, DATA_RAW, YEAR_DATA, "genital_warts.csv"))

# filter by years included in the calculation
genital_warts_data <- genital_warts_data |> 
  filter(year %in% YEAR_START:YEAR_CALCULATION) 

# genital warts data as in original script
GWincrate2002_20 <- genital_warts_data |> 
  pull(number) |> 
  matrix(nrow = N_SEX, byrow = TRUE)
