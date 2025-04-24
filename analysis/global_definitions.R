# data paths
DATA_DIR <- "data"
DATA_RAW <- "raw"
DATA_PROCESSED <- "processed"
DATA_EXPORT <- "export"

## path to where survival data is stored
# only if access to internal data storage
DIR_SURVIVAL_DATA <- "path_to_survival_data"

# The number of years previous to YEAR_CALCULATION TO INCLUDE IN THE EXPORT
NUM_YEARS <- 4

# from which year the data should be used to base the calculations on
# YEAR_DATA >= YEAR_CALCULATION
YEAR_DATA <- 2023
# year for which burden calculation needs to be done
YEAR_CALCULATION <- 2023
stopifnot(YEAR_DATA >= YEAR_CALCULATION)

# incidence data starts at year 1989 on NKR website
YEAR_START <- 1989
# total number of years
N_YEARS <- YEAR_CALCULATION - YEAR_START + 1

# number of sexes
N_SEX <- 2



# dictionary of cancer sites and ordering. Helper for calculations
CANCER_SITES <- tribble(
  ~cancer_site,           ~abbreviation, ~order_site,
  "Baarmoederhalskanker", "CE",          1,
  "Schaamlipkanker",      "VU",          2,
  "Vaginakanker",         "VA",          3,
  "Anuskanker",           "AN",          4,
  "Orofarynxkanker",      "ORO",         5,
  "Mondholtekanker",      "OC",          6,
  "Strottenhoofdkanker",  "LA",          7,
  "Peniskanker",          "PE",          8,
  "Keelholtekanker",      "PH",          9
) |>
  mutate(cancer_site = cancer_site |> forcats::as_factor())

# number of cancer sites
N_SITES <- 8

# five year age groups
AGE_GROUPS <- tribble(
  ~age_group, ~order_age_group,
  "0-4",      1,
  "5-9",      2,
  "10-14",    3,
  "15-19",    4,
  "20-24",    5,
  "25-29",    6,
  "30-34",    7,
  "35-39",    8,
  "40-44",    9,
  "45-49",    10,
  "50-54",    11,
  "55-59",    12,
  "60-64",    13,
  "65-69",    14,
  "70-74",    15,
  "75-79",    16,
  "80-84",    17,
  "85+",      18
)

# number of age groups
N_AGE_GROUPS <- AGE_GROUPS |> nrow()

