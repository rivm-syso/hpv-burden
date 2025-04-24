################### deaths per year
# by sex, age group, year, site

# mondholte, keelholte
# https://nkr-cijfers.iknl.nl/viewer/sterfte-per-jaar?language=nl_NL&viewerId=939870fa-5f54-4daa-917d-0a004de5ec23

# strottenhoofd, anus, schaamlippen
# https://nkr-cijfers.iknl.nl/viewer/sterfte-per-jaar?language=nl_NL&viewerId=8505b99d-bf67-43c8-8ccc-1dc456a1224a

# vagina, baarmoederhals, penis
# https://nkr-cijfers.iknl.nl/viewer/sterfte-per-jaar?language=nl_NL&viewerId=ac1ce6f5-b7c2-43ca-85b8-059e5c42d6a5

# combine excelsheets into one tibble
deaths_data <- combine_excel_iknl(
  data_dir = fs::path(DATA_DIR, DATA_RAW, YEAR_DATA),
  outcome_var = "deaths",
  year_col = `Jaar van overlijden`,
  skip = 7,
  cancer_sites = CANCER_SITES
) 


# check that asterisk * is the only "teken" in the data
# the asterisk should reflect that the numbers are preliminary numbers
# In Dutch the data should say "Deze cijfers betreffen voorlopige gegevens."
check <- deaths_data |>
  pull(teken) |>
  unique()

if (length(check) > 1) {
  warning(check, " contains more than one sign other than '*': manually check the data if they need to be further processed" )
}


deaths_data <- deaths_data |>
  arrange_iknl_tibble()

deaths_data <- deaths_data |>
  mutate(sex = if_else(sex == "man", "M", "F"))

check2 <- deaths_data |>
  pull(cancer_site) |>
  unique()

# all cancer sites should be present in the deaths data except for Orofarynxkanker
deaths_cancer_sites <- CANCER_SITES$cancer_site[CANCER_SITES$cancer_site != "Orofarynxkanker"]
if (! all(deaths_cancer_sites %in% check2)) {
  warning("The cancer types in the deaths data are ", check2, "and do not match ", deaths_cancer_sites)
}



### Assumption: ORO site deaths are proportional to PHARYNX site deaths with proportional constant
### equal to proportional constant of ORO incidence ~ PHARYNX incidence per year and sex (aggregated over age groups)

pharynx_deaths <- deaths_data |>
  filter(cancer_site == "Keelholtekanker") |>
  group_by(year, sex) |>
  summarise(total_deaths = sum(number)) 


ratio_incidence <- incidence_data |>
  filter(cancer_site == "Keelholtekanker" | cancer_site == "Orofarynxkanker") |>
  group_by(sex, year, cancer_site) |>
  summarise(total_incidence = sum(number)) |>
  mutate(ratio = total_incidence / total_incidence[cancer_site == "Keelholtekanker"]) |>
  filter(cancer_site == "Orofarynxkanker") |>
  select(sex, year, ratio)

estimated_oro_deaths <- deaths_data |>
  filter(cancer_site == "Keelholtekanker") |>
  left_join(ratio_incidence, by = join_by(year, sex)) |>
  mutate(
    number = ratio * number,
    cancer_site = "Orofarynxkanker"
  )


deaths_data <- deaths_data |>
  bind_rows(estimated_oro_deaths) |>
  mutate(cancer_site = cancer_site |> forcats::as_factor())

# convert replace NA values
deaths_data <- deaths_data |>
  select(sex, cancer_site, age_group, year, number) |> 
  mutate(number = tidyr::replace_na(number, 0))


# write processed data to disk
deaths_data |>
  readr::write_csv(fs::path(DATA_DIR, DATA_PROCESSED, YEAR_CALCULATION, "deaths.csv"))
