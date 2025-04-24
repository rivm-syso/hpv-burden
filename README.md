# hpv-burden

This repository contains the code that is used to do the calculations for the burden of disease of HPV. These results are published each year in the report on The National Immunisation Programme in the Netherlands. See the 2023 report [here](https://www.rivm.nl/publicaties/rvp-2023).

The calculations uses among others open data from Netherlands Comprehensive Cancer Organisation [(IKNL)](https://iknl.nl/en). Data from IKNL are not owned by RIVM and therefore not included in this repository. The user will need to manually download data from IKNL in order to run the code. As data do not have a persistent identifier, it may be that results are not reproducible.


## Usage

### Prerequisites

The code is written in R. The analysis is done in separate scripts in `analysis`. Data description are provided in the subsection [Data](#data) below


### Installation

The hpvburden functionality can be installed as a package (requires the package [pak](https://pak.r-lib.org/)):
  
  pak::pak("rivm-syso/hpvburden")


### <a name="data"></a>Data

1. From IKNL cancer incidence and deaths data should be downloaded manually ([here](https://iknl.nl/nkr-cijfers)). The following cancer sites should be collected. Additionally, the data should be **5-year age group** and **sex** stratified, and collected for each **year of diagnosis** 1989 - {YEAR_CALCULATION}. (Region = Totaal, Stage = Totaal):
  
    i. "Baarmoederhalskanker"

    i. "Schaamlipkanker"
    
    i. "Vaginakanker"
    
    i. "Anuskanker"
    
    i. "Orofarynxkanker" (*not available for deaths data*)
    
    i. "Mondholtekanker" 
    
    i. "Strottenhoofdkanker"
    
    i. "Peniskanker"
    
    i. "Keelholtekanker"
    
1. Note that the IKNL website does not handle such a large data request at once, therefore, one should download the data in parts. In the 2023 case the incidence data was downloaded as follows (see comments in `get_incidence_data.R` and `get_deaths_data.R` in `analysis/data-prepare`):

    i. "Mondholte, Keelholte" [link]( https://nkr-cijfers.iknl.nl/viewer/incidentie-per-jaar?language=nl_NL&viewerId=3798b5d3-e6b8-4328-a69d-d8d3cbb3ea70)
    
    ii. "Orofarynx, strottenhoofd" [link]( https://nkr-cijfers.iknl.nl/viewer/incidentie-per-jaar?language=nl_NL&viewerId=987c2f56-29dc-469e-a6e1-56e0b701afac)
    
    i. "Anus, schaamlippen" [link](https://nkr-cijfers.iknl.nl/viewer/incidentie-per-jaar?language=nl_NL&viewerId=16576c5f-6ecd-4e15-bcd7-6225ab537ac2)
    
    i. "Vagina, baarmoederhals, penis" [link]( https://nkr-cijfers.iknl.nl/viewer/incidentie-per-jaar?language=nl_NL&viewerId=2fff2560-c547-4d68-a9a0-a3a751250fdb)

1. Files should be stored in `{DATA_DIR}/{DATA_RAW}/{YEAR_CALCULATION}`, subdirectory `incidence` for incidence data and subdirectory `deaths` for deaths data. 

1. Scripts `get_deaths_data.R` and `get_incidence_data.R` in `analysis/data-prepare` take care of reading in the excel sheets, combining them into tibbles, and renaming columns. The processed data is stored in csv files in `DATA_DIR/DATA_PROCESSED/YEAR_CALCULATION` with names `incidence.csv` and `deats.csv`


1. CIN2/3 lesion incidence: [RIVM](https://www.rivm.nl/sites/default/files/2023-10/Monitor-BVO-Baarmoederhalskanker-2022.pdf). The numbers should be put into the tibble that is created in `analysis/data-raw/cin23_data.R`. Locate: code line with comment "# !! ADD NEW DATA"

    i. total number of women that were screened (in 2022 referred to as *Deelname primair onderzoek*) 
    
    i. combined cin2/3 incidence (in 2022 referred to as *aantal deelnemers waar baarmoederhalskanker of een voorstadium hiervan werd gevonden*)


1. anogenital wart incidence over time and sex. This is reported in the [RVIM SOA annual report](https://www.rivm.nl/publicaties/sexually-transmitted-infections-in-netherlands-in-2022). However, since 2021, the calculation has been changed. Rather than copying the numbers from the report ask for assistance in the calculation of new numbers through soap@rivm.nl. The numbers should be put into the tibble that is created in `analysis/data-raw/genital_warts.R`. Locate the code line with comment "*# ! ADD NEW DATA*"


### Calculation

Global variables are set in `analysis/global_definitions.R`. Here the user can set data directories, the year of calculation of the burden etc. `analysis/main.R`  runs all the scripts in order to obtain the calculated burden. The resulting burden for the current year plus the past four years is exported with `analysis/export.R` to an excel file located in `{DATA_DIR}/{DATA_EXPORT}/{YEAR_CALCULATION}s`.


### Requirements

R session info:
  
```
R version 4.4.1 (2024-06-14)
Platform: x86_64-redhat-linux-gnu
Running under: Red Hat Enterprise Linux 8.10 (Ootpa)
```

Packages

```
cbsodataR (>= 1.1),
coda (>= 0.19),
dplyr (>= 1.1.4),
fs (>= 1.6.4),
ggplot2 (>= 2.3.5),
readxl (>= 1.4.3),
runjags (>= 2.2.2),
tibble (>= 3.2.1),
tidyr (>= 1.3.1)
```

## License

Copyright (c) 2024 Rijksinstituut voor Volksgezondheid en Milieu (RIVM), licensed under the EUPL v1.2

## Feedback

If you encounter a clear bug, please file an issue with a minimal reproducible example on GitHub.
