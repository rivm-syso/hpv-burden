# population data
file_name <- "population.csv"

# read cbs data from disk
if (fs::file_exists(fs::path(DATA_DIR, DATA_RAW, YEAR_DATA, file_name))) {
  individual_cbs_data <-
    readr::read_csv(fs::path(DATA_DIR, DATA_RAW, YEAR_DATA, file_name))
} else {# get population data from CBS and transform

  # table: extract table id
  table_id <- cbsodataR:::cbs_extract_table_id(url = "https://opendata.cbs.nl/statline/#/CBS/nl/dataset/7461bev/table?ts=1649948794215")

  # get the metadata from Statistics Netherlands
  meta_data <- cbsodataR::cbs_get_meta(table_id)

  # define keys to select records from Statistics Netherlands data
  gender_keys <- meta_data$Geslacht |>
    filter(Title %in% c("Mannen", "Vrouwen")) |>
    pull(Key)

  age_keys <- meta_data$Leeftijd |>
    filter(CategoryGroupID == 2 & Title != "99 jaar") |>
    pull(Key)
  
  burgelijke_staat_keys <- meta_data$BurgerlijkeStaat |> 
    filter(Title == "Totaal burgerlijke staat") |> 
    pull(Key)

  # get the (aggregated) data from Statistics Netherlands
  # below is syntax for filtering data using the functionality of
  # the function cbs_get_data from the cbsodataR package
  # see also `help(cbsodataR::cbs_get_data)`

  individual_cbs_data <- cbsodataR::cbs_get_data(
    # table identifier
    id = table_id,
    # gender specification
    Geslacht = gender_keys,
    # age specification
    Leeftijd = age_keys,
    # registration year specification: all years
    Perioden = meta_data$Perioden |> pull(Key),
    BurgerlijkeStaat = burgelijke_staat_keys
  )

  # add columns with labels using the functionality of
  # the function cbs_add_label_columns from the cbsodataR package
  # see also `help(cbsodataR::cbs_add_label_columns)`
  individual_cbs_data <- individual_cbs_data |>
    cbsodataR::cbs_add_label_columns()

  # write to disk
  individual_cbs_data |>
    readr::write_csv(fs::path(DATA_DIR, DATA_RAW, YEAR_CALCULATION, file_name))
}


# ---------------------------------------------------------
# Transform data to prepare for calculate.R script

# select and rename relevant columns
individual_cbs_data <- individual_cbs_data |>
  select(
    sex = Geslacht_label,
    age = Leeftijd_label,
    year = Perioden_label,
    count = Bevolking_1
  )

# transform variables
individual_cbs_data <- individual_cbs_data |>
  mutate(
    # make sex a factor with new labels
    sex = sex |>
      case_match(
        "Vrouwen" ~ "F",
        "Mannen" ~ "M",
        .default = sex
      ) |>
      factor() |>
      # reverse order: men before women in accordance with Calc_HPV_burden_update2022.R script
      forcats::fct_rev(),
    # make count numeric
    count = count |> as.numeric(),
    # drop the "jaar" in age
    age = age |> stringr::str_extract("\\d+") |> as.numeric()
  ) |> 
  filter(age <= 99) # 99 corresponds to 99 years and older


# transform data in format used in calculate.R script: order of sex and age
individual_cbs_data <- individual_cbs_data |>
  # consider only the years for the calculation
  filter(year %in% YEAR_START:YEAR_CALCULATION) |>
  # make five year age groups and sum numbers
  mutate(age_group = make_age_groups(age, max_age = 85, age_group_band = 5)) |>
  group_by(sex, age_group, year) |>
  summarise(count = sum(count, na.rm = TRUE)) |>
  # helper to order age groups
  left_join(AGE_GROUPS, by = join_by(age_group)) |> 
  # arrange
  arrange(sex, order_age_group, year) |> 
  select(-order_age_group)

# write processed data to disk
individual_cbs_data |>
  readr::write_csv(fs::path(DATA_DIR, DATA_PROCESSED, YEAR_CALCULATION, file_name))
