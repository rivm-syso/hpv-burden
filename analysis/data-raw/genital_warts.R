# genital warts incidence
# Available: M/F incidences from 2002-2011, based on GP consult.rates for 
# GWs per 100,000 and M/F incidence from 2012-2020, (as per 1,000). Now we take 
# figures from the SOA annual reports eg. Table 7.1. 
# Last update (for 2017 t/m 2020 was from 2021 report).
# NB. the COVID-19 pandemic may have led to the lower 2020 values due to reduced 
# GP access, or the drop may be real.

GENITAL_WARTS <- tribble(
  ~sex, ~year, ~number,
  "M",  2002,  70.8,
  "M",  2003,  64.9,
  "M",  2004,  80.3,
  "M",  2005,  93.9,
  "M",  2006,  82.7,
  "M",  2007,  86.7,
  "M",  2008,  121.6,
  "M",  2009,  140.2,
  "M",  2010,  139.0,
  "M",  2011,  146.1,
  "M",  2012,  230,
  "M",  2013,  250,
  "M",  2014,  250,
  "M",  2015,  250,
  "M",  2016,  259,
  "M",  2017,  290,
  "M",  2018,  310,
  "M",  2019,  310,
  "M",  2020,  310,
  "F",  2002,  76.5,
  "F",  2003,  67.7,
  "F",  2004,  79.3,
  "F",  2005,  83.3,
  "F",  2006,  107.2,
  "F",  2007,  108.4,
  "F",  2008,  122.7,
  "F",  2009,  122.4,
  "F",  2010,  118.1,
  "F",  2011,  142.2,
  "F",  2012,  180,
  "F",  2013,  190,
  "F",  2014,  200,
  "F",  2015,  190,
  "F",  2016,  186,
  "F",  2017,  200,
  "F",  2018,  210,
  "F",  2019,  230,
  "F",  2020,  220,  
  "F",  2021,  220,
  "F",  2022,  210,
  "M",  2021,  340,
  "M",  2022,  330
  # ! ADD NEW DATA
) |> 
  arrange(sex |> forcats::fct_rev(), year) |> 
  readr::write_csv(fs::path(DATA_DIR, DATA_RAW, YEAR_DATA, "genital_warts.csv"))