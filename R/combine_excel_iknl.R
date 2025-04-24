#' Combines excel files that are downloaded from IKNL
#' 
#' @description see README for instructions on which data to download, how and where
#'
#' @param data_dir path where data is located
#' @param outcome_var string indicating the outcome variable "incidence" or "death" 
#' @param cancer_sites tibble containing columns `cancer_site`, `abbreviation` and `order_site`. Refer to CANCER_SITES in global_definitions.R 
#' @param year_col string indicating the column for the year under consideration
#' @param skip int - number of rows to skip
#' @param sign boolean - whether there is an asterisk after the year in the data, in which case it is removed from the data. Default is TRUE
#'
#' @return tibble containing the data in the excelsheets
#' @export
combine_excel_iknl <- function(data_dir, outcome_var, cancer_sites, year_col, skip, sign = TRUE) {
  df <- fs::dir_map(
    fs::path(data_dir, outcome_var), fun = \(x) {
      # read raw excel file
      df <- readxl::read_excel(fs::path(x), sheet = 1, skip = skip)
    }
  ) |> 
    bind_rows() |>
    mutate(Leeftijdsgroep = forcats::as_factor(Leeftijdsgroep)) |>
    left_join(cancer_sites, by = join_by(Kankersoort == cancer_site)) |> 
    rename(year = {{ year_col }})
    
  if (sign) {
    # separate year and sign
    df <- df |>
      tidyr::separate_wider_regex(year, c(year = "\\d{4}", teken = ".*")) |>
      select(-Teken)
  }

  return(df)
}


#' Arranges IKNL data in the order that is assumed for the calculation.R script to work
#'
#' @param data tibble - the output of `combine_excel_iknl`
#' @param df_age_groups tibble - columns `age_group` and `order_age_group` containing 
#' the age group labels and order of age groups as they are assumed in the calculate.R script. 
#' Refer to global_definitions.R
#'
#' @return tibble containing the same data as input data but then rearranged
#' @export
arrange_iknl_tibble <- function(data, df_age_groups = AGE_GROUPS) {
  data <- data |> 
    left_join(df_age_groups, by = join_by(Leeftijdsgroep == age_group)) |> 
    # order that is used in calculate.R script
    arrange(Geslacht, order_site, order_age_group, year) |> 
    # select relevant columns
    select(sex = Geslacht, cancer_site = Kankersoort, age_group = Leeftijdsgroep, year, number = Aantal) |> 
    # correct data types of columns
    mutate(year = year |> as.numeric(),
           sex = sex |> forcats::as_factor() |> forcats::fct_recode(man = "Man", woman = "Vrouw"),
           cancer_site = cancer_site |> forcats::as_factor())
  return(data)
}
