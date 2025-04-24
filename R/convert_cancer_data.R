#' Convert cancer incidence and deaths data into arrays that are assumed in calculate.R
#'
#' @param .data tibble - output of `arrange_iknl_tibble`
#' @param select_sex character - indicating males or females `M` or `F`
#' @param select_cancer_site character - cancer site, refer to tibble in global_defintions.R
#' @param value_col character - column name of column containing the incidence or deaths numbers
#' @param df_age_groups tibble - columns `age_group` and `order_age_group` containing 
#' the age group labels and order of age groups as they are assumed in the calculate.R script. 
#' Refer to global_definitions.R
#'
#' @return array
#' @export
convert_cancer_data <- function(.data, select_sex, select_cancer_site, value_col, df_age_groups = AGE_GROUPS) {
  .data <- .data |>
    filter(sex == select_sex, cancer_site == select_cancer_site) |>
    tidyr::pivot_wider(names_from = year, values_from = {{ value_col }}) |> 
    left_join(df_age_groups, by = join_by(age_group)) |> 
    arrange(order_age_group) |> 
    select(-c(sex, cancer_site, age_group, order_age_group)) |>
    as.matrix()
  # convert into numeric matrix
  .data <- .data |> 
    as.numeric() |> 
    matrix(nrow = .data |> nrow())
  return(.data)
}
