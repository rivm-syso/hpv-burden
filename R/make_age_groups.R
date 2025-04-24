#' Helper function to make age groups from a column that contains age by year
#'
#' @param age_col_name data variable - name of the column that contains the
#' ages by year that should be assigned to age groups. Or vector with numeric 
#' values that should be grouped into age groups
#' @param max_age int - lower bound of the oldest age group. Default 80 years,
#' i.e. the oldest age group is 80+
#' @param age_group_band int - width of the age group, default is 10 years, e.g.
#' age groups are 0-9, 10-19, etc
#'
#' @return vector with age groups
#' @export
make_age_groups <- function(
    age_col_name,
    max_age = 80,
    age_group_band = 10) {
  age_groups <- c(seq(0, max_age, age_group_band), Inf)
  age_groups_labels <- c(
    paste0(
      seq(0, max_age - age_group_band, age_group_band),
      "-",
      seq(age_group_band - 1, max_age - 1, age_group_band)
    ),
    paste0(max_age, "+")
  )
  age_group <- cut({{ age_col_name }},
                   breaks = age_groups, include.lowest = TRUE, right = FALSE,
                   labels = age_groups_labels
  )
  return(age_group)
}
