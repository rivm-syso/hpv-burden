library(hpvburden)
library(dplyr)
library(ggplot2)

# global definitions used in the calculations: parameter values etc
source("analysis/global_definitions.R")

# create directories if not already present
c(DATA_RAW, DATA_PROCESSED, DATA_EXPORT) |> purrr::walk(\(x)
  fs::dir_create(DATA_DIR, x, YEAR_CALCULATION)
)

###
if (!fs::file_exists(fs::path(DATA_DIR, DATA_PROCESSED, YEAR_CALCULATION, "genital_warts.csv"))) {
  source("analysis/data-raw/genital_warts.R")
}
if (!fs::file_exists(fs::path(DATA_DIR, DATA_PROCESSED, YEAR_CALCULATION, "cin23.csv"))) {
  source("analysis/data-raw/cin23_data.R")
}
if (!fs::file_exists(fs::path(DATA_DIR, DATA_PROCESSED, YEAR_CALCULATION, "life_expectancy.csv"))) {
  source("analysis/data-raw/life_expectancy.R")
}

### get data if not already on disk
if (!fs::file_exists(fs::path(DATA_DIR, DATA_PROCESSED, YEAR_CALCULATION, "population.csv"))) {
  # CBS
  source("analysis/data-prepare/get_population_data.R")
}
# IKNL
if (!fs::file_exists(fs::path(DATA_DIR, DATA_PROCESSED, YEAR_CALCULATION, "incidence.csv"))) {
  source("analysis/data-prepare/get_incidence_data.R")
}
if (!fs::file_exists(fs::path(DATA_DIR, DATA_PROCESSED, YEAR_CALCULATION, "deaths.csv"))) {
  source("analysis/data-prepare/get_deaths_data.R")
}

### prepare data for calculation script
source("analysis/data-prepare/prepare_incidence_deaths_data.R")
source("analysis/data-prepare/prepare_population_data.R")
source("analysis/data-prepare/prepare_life_expectancy_data.R")
source("analysis/data-prepare/prepare_survival_data.R")
source("analysis/data-prepare/prepare_cin23_data.R")
source("analysis/data-prepare/prepare_genital_warts_data.R")

### calculate burden
logger::log_info(paste0("Calculating HPV burden for years ", 
                        YEAR_CALCULATION - 4, " until ", YEAR_CALCULATION, 
                        "\n based on data from ", YEAR_DATA))
source("analysis/calculate.R")
# outputs result DALYAll_median_95CI

### export results
source("analysis/export.R")
