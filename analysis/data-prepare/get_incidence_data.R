################### incidence per year
# by sex, age group, year, site
## NEEDS TO BE DOWNLOADED manually from NKR website

### urls for the year 2023

# mondholte, keelholte
# https://nkr-cijfers.iknl.nl/viewer/incidentie-per-jaar?language=nl_NL&viewerId=3798b5d3-e6b8-4328-a69d-d8d3cbb3ea70

# orofarynx, strottenhoofd
# https://nkr-cijfers.iknl.nl/viewer/incidentie-per-jaar?language=nl_NL&viewerId=987c2f56-29dc-469e-a6e1-56e0b701afac

# anus, schaamlippen
# https://nkr-cijfers.iknl.nl/viewer/incidentie-per-jaar?language=nl_NL&viewerId=16576c5f-6ecd-4e15-bcd7-6225ab537ac2

# vagina, baarmoederhals, penis
# https://nkr-cijfers.iknl.nl/viewer/incidentie-per-jaar?language=nl_NL&viewerId=2fff2560-c547-4d68-a9a0-a3a751250fdb


#################
file_name <- "incidence.csv"

# combine excelsheets into one tibble
incidence_data <- combine_excel_iknl(data_dir = fs::path(DATA_DIR, DATA_RAW, YEAR_DATA), 
                                     outcome_var = "incidence", 
                                     cancer_sites = CANCER_SITES, 
                                     skip = 9,
                                     year_col = `Jaar van diagnose`) 

# check that asterisk * is the only "teken" in the data
# the asterisk should reflect that the numbers are preliminary numbers
# In Dutch the data should say "Deze cijfers betreffen voorlopige gegevens."
check <- incidence_data |> 
  pull(teken) |> 
  unique()
if (length(check) > 1) {
  warning(check, " contains more than one sign other than '*': manually check the data if they need to be further processed" )
}


check2 <- incidence_data |> 
  pull(Kankersoort) |> 
  unique()

# all cancer sites should be present in the deaths data except for Orofarynxkanker
incidence_cancer_sites <- CANCER_SITES$cancer_site
if (! all(incidence_cancer_sites %in% check2)) {
  warning("The cancer types in the incidence data are ", check2, "and do not match ", incidence_cancer_sites)
}


incidence_data <- incidence_data |> 
  arrange_iknl_tibble()

incidence_data <- incidence_data |> 
  mutate(sex = if_else(sex == "man", "M", "F"),
         number = tidyr::replace_na(number, 0)) 

# write processed data to disk
incidence_data |> 
  readr::write_csv(fs::path(DATA_DIR, DATA_PROCESSED, YEAR_CALCULATION, file_name))


incidence_data |> head()

# plot cancer incidence, cervis only, separate age groups
incidence_data |> 
  filter(cancer_site == "Baarmoederhalskanker", sex == "F") |> 
  ggplot(aes(x = year, y = number, col = age_group)) + 
  geom_point() + 
  geom_line()

# total incidence by sex, cancer site and year, summed over age groups
incidence_data |> 
  group_by(sex, cancer_site, year) |> 
  summarise(total_incidence = sum(number))

