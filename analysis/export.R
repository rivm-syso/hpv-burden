# write result to excel file and make plots for sharing

library(ggplot2)
library(xlsx)

# DALYAll_median_95CI
# 1: sex - M, F
# 2: years: 1989, 1990, ..., YEAR_CALCULATION
# 3: summary - median, 2.5%, 97.5%

# prepare for excel
# column names
cols <- c("DALY-median", "DALY-2.5%", "DALY-97.5%")

# separate men and women
df_men <- DALYAll_median_95CI[1, , ] |> round()
colnames(df_men) <- cols

df_women <- DALYAll_median_95CI[2, , ] |> round()
colnames(df_women) <- cols

df_men <- df_men |>
  as_tibble() |>
  tibble::add_column(sex = "M", .before = 1) |>
  tibble::add_column(year = YEAR_START:YEAR_CALCULATION, .before = 1)

df_women <- df_women |>
  as_tibble() |>
  tibble::add_column(sex = "F", .before = 1) |>
  tibble::add_column(year = YEAR_START:YEAR_CALCULATION, .before = 1)

# add tibbles
df <- df_men |>
  bind_rows(df_women)

# round to the nearest 100 DALYs to avoid false precision
df <- df |> 
  mutate(across(!c(year, sex), \(x) round(x / 100) * 100))

# years of interest for exporting
years <- (YEAR_CALCULATION - NUM_YEARS):YEAR_CALCULATION

# format tibble
output <- years |>
  purrr::map(\(x) {
    df |>
      filter(year == x) |>
      tidyr::pivot_wider(
        names_from = year,
        values_from = c(`DALY-median`, `DALY-2.5%`, `DALY-97.5%`),
        names_glue = "{.value}"
      ) |>
      select(-sex)
  })

# format for export
output <- output |>
  bind_cols(.name_repair = "minimal") |>
  tibble::add_column(sex = c("M", "F"), .before = 1, .name_repair = "minimal")

#### format excel

# create workbook
wb <- createWorkbook(type = "xlsx")
# Title and sub title styles
TITLE_STYLE <- CellStyle(wb) + Font(wb,
  heightInPoints = 14,
  color = "blue", isBold = TRUE, underline = 1
)

YEAR_STYLE <- CellStyle(wb) + Font(wb,
  heightInPoints = 12,
  color = "blue", isBold = TRUE
)
# Create a new sheet in the workbook
#++++++++++++++++++++++++++++++++++++
sheet <- createSheet(wb, sheetName = "burden")

#++++++++++++++++++++++++
# Helper function to add titles
#++++++++++++++++++++++++
# - sheet : sheet object to contain the title
# - rowIndex : numeric value indicating the row to
# contain the title
# - title : the text to use as title
# - titleStyle : style object to use for title
xlsx.addTitle <- function(sheet, rowIndex, title, titleStyle) {
  rows <- createRow(sheet, rowIndex = rowIndex)
  sheetTitle <- createCell(rows, colIndex = 1)
  setCellValue(sheetTitle[[1, 1]], title)
  setCellStyle(sheetTitle[[1, 1]], titleStyle)
}

xlsx.addYear <- function(sheet, rowIndex, colIndex, year) {
  sheetTitle <- createCell(year_rows, colIndex = colIndex)
  setCellValue(sheetTitle[[1, 1]], year)
  setCellStyle(sheetTitle[[1, 1]], YEAR_STYLE)
}


# Add title and sub title into a worksheet
#++++++++++++++++++++++++++++++++++++
# Add title
xlsx.addTitle(sheet,
  rowIndex = 1,
  title = paste0("ESTIMATED BURDEN FOR THE ", YEAR_CALCULATION + 1, " RVP REPORT"),
  titleStyle = TITLE_STYLE
)

year_rows <- createRow(sheet, rowIndex = 3)
years |> 
  purrr::imap(\(x, idx) {
  xlsx.addYear(sheet, colIndex = 3 * idx, year = x)
})


# Add a table into a worksheet
#++++++++++++++++++++++++++++++++++++
addDataFrame(output, sheet, startRow = 4, startColumn = 1)

# Change column width
setColumnWidth(sheet, colIndex = c(1:ncol(output)), colWidth = 15)


# Save the workbook to a file...
#++++++++++++++++++++++++++++++++++++
saveWorkbook(wb, fs::path(DATA_DIR, DATA_EXPORT, YEAR_CALCULATION, glue::glue("RVP_report_HPV_BURDEN_{YEAR_CALCULATION - NUM_YEARS}_{YEAR_CALCULATION}.xlsx")))


###################################################################
# plot cervical cancer incidence over time

p <- incidence_data |>
  filter(
    cancer_site == "Baarmoederhalskanker",
    sex == "F",
    age_group %in% c("30-34", "40-44", "50-54", "60-64", "70-74", "80-84")
  ) |>
  ggplot(aes(x = year, y = number, col = age_group)) +
  geom_line() +
  geom_point() +
  labs(title = "Incidence per year, NKR numbers") +
  theme_minimal()

ggsave(fs::path(DATA_DIR, DATA_EXPORT, YEAR_DATA, "incidentie_baarmoederhalskanker.pdf"), 
       width = 20, height = 10, units = "cm", p)