## CIN2/3 lesion incidence as it is assumed and estimated from literature and data
# additional assumptions are made in form of correction factors to obtain estimates 
# for total detection of CIN2 and CIN3

# Estimate CIN2/3 lesion incidence separately for two periods: 1989-2004 and 2005-2014.
# Note: For *2005 through 2014* only, actual data were obtained from charts and tables
# Note: For 1990-2004, estimated from de Kok et al. 2011
# Note: 2014 values are updated from values used in CC&C. (from Table 4, 2015 LEBA reports)
# Note: in 2017 report, 2017 directe verwijzing numbers [Fig 6] are referred to as 
# 'eerste indicatie', and are much higher than previous years due to 
# vernieuwd bevolkingsonderzoek!  
#
# Values for 2019 are from pdf 'monitor bevolkingsonderzoek baarmoederhalskanker 2020' 
#
# Values for 2021 from pdf 'monitor bevolkingsonderzoek baarmoederhalskanker 2021'

TotalScreened2017 <- 470412
RateToCases2017 <- TotalScreened2017 / 100000
adjDirectToTotal <- (5035 - 547) / 5035 # based on 2018 data, 0.8914 of all CIN2/3 directe

cin23_data <- tribble(
  ~year, ~total_screened, ~combined_cin23,
  2018, 460474, 5035,
  2019, 452616, 4982,
  2020, 296487, 3413,
  2021, 555515, 6246,
  2022, 333657, 3642
  # !! ADD NEW DATA
) |>
  mutate(
    estimated_cin2 = round(combined_cin23 * 0.45 * (500000 / total_screened)),
    estimated_cin3 = round(combined_cin23 * 0.55 * (500000 / total_screened))
  ) |>
  add_row(
    # special case 2017
    year = 2017,
    total_screened = 470412,
    estimated_cin2 = round(415 / adjDirectToTotal * RateToCases2017 * (500000 / TotalScreened2017)), # we adjust direct inc rates to estimate totals,
    estimated_cin3 = round(586 / adjDirectToTotal * RateToCases2017 * (500000 / TotalScreened2017)) # and extrapolate cases to 500,000 women to be consistent with other N_YEARS
  ) |>
  add_row(
    # special cases 2005 - 2016
    year = 2005:2016,
    estimated_cin2 = c(99, 102, 103, 113, 134, 154, 164, 167, 162, 167, 190, 186) * 2.53 * 5,
    estimated_cin3 = c(291, 298, 336, 358, 405, 410, 424, 413, 415, 430, 445, 452) * 1.54 * 5
  ) |>
  # combined cin2 and cin3
  mutate(combined_cin23 = estimated_cin2 + estimated_cin3) |>
  add_row(
    # special cases 1989-2004
    year = 1989:2004,
    combined_cin23 = c(3268, 3304, 3233, 3373, 3173, 3385, 3396, 3796, 3792, 3745, 3490, 3372, 3547, 3435, 3395, 3371) * 0.943
  ) |> 
  # order by year
  arrange(year) |> 
  select(year, total_screened, combined_cin23)

cin23_data |> 
  readr::write_csv(fs::path(DATA_DIR, DATA_RAW, YEAR_DATA, "cin23_data.csv"))
