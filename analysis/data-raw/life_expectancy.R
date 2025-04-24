## Get NL 5-yr width life-expectancy: 0-4 to 85+ (age=0,5,10,15,..85)
# (CURRENT) use (for NIP reports to allow comparison to other VPD, LEs as used for SvI) 
# GBD-2010 tables: Murray CJ, et al. GBD 2010: design, definitioN_SITES, and metrics. 
# The Lancet. 2012 Dec 15;380(9859):2063-6.
LIFE_EXPECTANCY <- tribble(
  ~age_group, ~order_age_group, ~expected, 
  "0-4",      1,                85.68,
  "5-9",      2,                78.76,
  "10-14",    3,                73.79,
  "15-19",    4,                68.83,
  "20-24",    5,                63.88,
  "25-29",    6,                58.94,
  "30-34",    7,                54,
  "35-39",    8,                49.09,
  "40-44",    9,                44.23,
  "45-49",    10,               39.43,
  "50-54",    11,               34.72,
  "55-59",    12,               30.1,
  "60-64",    13,               25.55,
  "65-69",    14,               21.12,
  "70-74",    15,               16.78,
  "75-79",    16,               12.85,
  "80-84",    17,               9.34,
  "85+",      18,               5.05
) |> 
  readr::write_csv(fs::path(DATA_DIR, DATA_RAW, YEAR_DATA, "life_expectancy.csv"))
