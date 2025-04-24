#############################################################
# HPV burden projection project -
# estimate in Bayesian context for uncertainty propagation
#############################################################

# load libraries
library(runjags)
library(coda)


# total population sizes
populNL_total <- apply(populNL, c(1, 3), sum)

# total incidence
inc.tot <- apply(inc[, , 1:N_YEARS, ], c(1, 3, 4), sum)


## Case fatality - age-group unspecific
#  If only t/m (N_YEARS - 1)[=2020] deaths data available, the CFR is based only on death-to-case-ratio 1989 tm 2020  (if so: (N_YEARS - 1) = N_YEARS - 1)
# ** Deaths are not projected into future, the cfr is thus based on the death-to-case ratio from 1989-2020
# death-to-case ratio, indep of age and time  - THIS IS PROXY FOR REAL CFR OR CURE MODEL
cfrSexSite <- array(NA, dim = c(2, N_SITES))
cfrSexSite <- round(apply(dths, c(1, 4), sum) / apply(inc[, , 1:(N_YEARS - 1), ], c(1, 4), sum), 4) # NB. male cells for female cancers and v.v are NaN
cfrSexSite <- ifelse(is.nan(cfrSexSite), NA, cfrSexSite)
cfrSexSite


## CASE-FATALITY FOR ORO & OC SITES, CFR IS ADUSTED FOR BETTER PROGNOSIS FOR HPV+ - see JAGS code, below
#  [HRs from literature search using eg. mortality OR death "relative risk" OR "odds ratio" hpv infection penile OR penis cancer]
dthsbyfupyr <- array(0, dim = c(2, N_AGE_GROUPS, 10, N_SITES))
# First count how many deaths in each follow-up year, from 10-year rel surv data. Assumed no deaths after 10 N_YEARS post-diagnosis!
# in a hypothetical cohort of 1  NB. [,,1] is first follow-up year
dthsbyfupyr[, , 1, ] <- 1 - surv[, , 1, ]
# set deaths to zero in case of sex-specific sites
dthsbyfupyr[, , 1, ] <- ifelse(dthsbyfupyr[, , 1, ] == 1, 0, dthsbyfupyr[, , 1, ])
# estimate mortality in each follow-up year, as difference in mortality in previous year
for (fupyr in 2:10) {
  # pmax() is to ensure that dthsbyfupyr does not go negative
  dthsbyfupyr[, , fupyr, ] <- pmax(surv[, , fupyr - 1, ] - (surv[, , fupyr, ]), 0)
}
totdths <- apply(dthsbyfupyr, c(1, 2, 4), sum)
# Mean time from diagnosis until death (meanPT) is number of dths in each interval x interval-length, divided by total number of dths in 'cohort'
# All deaths assumed to occur in midpoint of each interval, for simplicity
meanPT <- ((dthsbyfupyr[, , 1, ] * 0.5) + (dthsbyfupyr[, , 2, ] * 1.5) + (dthsbyfupyr[, , 3, ] * 2.5) + (dthsbyfupyr[, , 4, ] * 3.5) + (dthsbyfupyr[, , 5, ] * 4.5) +
  (dthsbyfupyr[, , 6, ] * 5.5) + (dthsbyfupyr[, , 7, ] * 6.5) + (dthsbyfupyr[, , 8, ] * 7.5) + (dthsbyfupyr[, , 9, ] * 8.5) +
  (dthsbyfupyr[, , 10, ] * 9.5)) / totdths
# replace NaN w/ NA; essential for JAGS
meanPT <- ifelse(is.nan(meanPT), NA, meanPT)


## Population attributable fractions for HPV (typically est. as prevalence of HPV in tumour)
# NB. adjustment for OR-sex in JAGS code.
paf_a <- array(matrix(c(
  2903, 165, 108, 148, NA, 6, 7, 53,
  2903, 165, 108, 148, NA, 6, 7, 53
), byrow = TRUE, nrow = 2, ncol = N_SITES), dim = c(2, N_SITES, N_YEARS))

# allowed to vary by sex, site and over time (*only* ORO site varies over time)
paf_a <- aperm(paf_a, c(1, 3, 2))

paf_b <- array(matrix(c(
  (3162 - 2903), (903 - 165), (152 - 108), (169 - 148), NA, (106 - 6), (58 - 7), (210 - 53),
  (3162 - 2903), (903 - 165), (152 - 108), (169 - 148), NA, (106 - 6), (58 - 7), (210 - 53)
), byrow = TRUE, nrow = 2, ncol = N_SITES), dim = c(2, N_SITES, N_YEARS))
paf_b <- aperm(paf_b, c(1, 3, 2))

# Allow oropharynx PAF to vary over time, applying Rietbergen et al's values
# for specific years for the previous two and subsequent two years
# 1990: 2/39  1995: 3/37  2000: 6/43  2005:12/59  2010: 18/62
# NOW combining these 5-yearly figures with more recent, annual, data [tm 2015]
# (Rietbergen, Int J Cancer 2018; Fig 1): 8-6-2020:
# NB. values 30 and (61-30) for 2015 ar carried over to years 2016,2017,2018,2019,2020,2021 & 2022 (ie. N_YEARS-26)
paf_a[, 1:(N_YEARS), ORO] <- matrix(
  c(
    rep(2, 4), rep(3, 5), rep(6, 3), 7, 12,
    12, 15, 11, 16, 9, 12, 21, 18,
    27, 30, 31, 26, rep(30, (N_YEARS - 26))
  ),
  nrow = 2, ncol = (N_YEARS), byrow = TRUE
)

paf_b[, 1:(N_YEARS), ORO] <- matrix(
  c(
    rep((39 - 2), 4), rep((37 - 3), 5), rep((43 - 6), 3), (56 - 7), (65 - 12),
    (61 - 12), (51 - 15), (58 - 11), (60 - 16), (36 - 9), (44 - 12), (50 - 21),
    (62 - 18), (57 - 27), (76 - 30), (69 - 31), (70 - 26), rep((61 - 30), (N_YEARS - 26))
  ),
  nrow = 2, ncol = N_YEARS, byrow = TRUE
)


## Time to cure (N_YEARS) from Soerjomataram et al (2012, BMC) -
# assumed invariant across sex, age, and time
cureTime <- c(4, 4, 8, 7, 7, 7, 5, 10)
# Proxies: vulva ~ Cervix; vagina ~ Ovary; anus ~ Colorectum; oropharaynx ~ Other pharynx; penis ~ Prostate
# Proxy sites were chosen based on similar relative survival

# Use [site-specific] weights for four possible stages ( DW[,1:4] ),
# taken from Soerjomataram et al (2012, BMC)
DW <- array(0, dim = c(4, N_SITES))
DW[1, ] <- c(0.43, 0.43, 0.43, 0.43, 0.56, 0.56, 0.56, 0.27)
DW[2, ] <- c(0.20, 0.20, 0.20, 0.20, 0.37, 0.37, 0.37, 0.18)
DW[3, ] <- c(0.75, 0.75, 0.75, 0.83, 0.90, 0.90, 0.90, 0.64)
DW[4, ] <- c(0.93, 0.93, 0.93, 0.93, 0.93, 0.93, 0.93, 0.93)



## Estimate DD for each 5-year age-group per sex, for each cancer site, using survival data from NKR and
# site-specific average time-to-cure values from Soerjomataram et al (2012)
# Estimate the product [DW x DD] separately for survivors and non-survivors
# (as these consist of different stages and dws)
# Assumed that dw for time lived following a cure is *zero*
DWxDDSexAgeSite <- array(NA, dim = c(2, N_AGE_GROUPS, N_SITES))
survSexAgeSite <- array(NA, dim = c(2, N_AGE_GROUPS, N_SITES))
nonsurvSexAgeSite <- array(NA, dim = c(2, N_AGE_GROUPS, N_SITES))
meanYrsLost <- array(NA, dim = c(2, N_AGE_GROUPS, N_SITES))
meanYrsAlive <- array(NA, dim = c(2, N_AGE_GROUPS, N_SITES))
cappedCureTime <- array(NA, dim = c(2, N_AGE_GROUPS, N_SITES))
RLE <- array(NA, dim = c(2, N_AGE_GROUPS, N_SITES))
state_diag <- array(NA, dim = c(2, N_AGE_GROUPS, N_SITES))
state_ctrl <- array(NA, dim = c(2, N_AGE_GROUPS, N_SITES))


# For *non-survivors*, calculate disability incurred before time of death,
# and mean years of life lost (from survivak curves):
# The latter is (LE[age@death]), where age@death = (midpoint-agegrp@diag + mean time until death)
for (g in 1:2) {
  for (a in 1:N_AGE_GROUPS) {
    for (site in 1:N_SITES) {
      # mean time until death per pt, given that pt died (based on agegrp-specific 10-yr rel surv)
      meanYrsAlive[g, a, site] <- meanPT[g, a, site]
      # [DW x duration] for time alive between cancer diagnosis & deaths
      # Retrieve remaining life expectancy at age[-group] of death. Eg. male 80-84 N_YEARS [agegrp 17] has mean time to death of 3.652 N_YEARS.
      nonsurvSexAgeSite[g, a, site] <- (2 / 12 * DW[1, site]) + ((meanYrsAlive[g, a, site] - 2 / 12 - 4 / 12) * DW[2, site]) +
        (3 / 12 * DW[3, site]) + (1 / 12 * DW[4, site])
      # If man dies of penile cancer, age at death is 80-84 + 3.652; so agegrp at death is 85-89 [18], which has associated RLE of 5.82 N_YEARS
      meanYrsLost[g, a, site] <- lifeExpNL[g, min(N_AGE_GROUPS, round((((a - 1) * 5 + 2.5) + meanPT[g, a, site]) / 5) + 1)]
    }
  }
}

# For *survivors*, all disability is incurred before cure time, w/ cure time
# capped by RLE at age@registration; assumed dw=0 after cure:
for (site in 1:N_SITES) {
  # cap time-to-cure at exp. remaining LE
  cappedCureTime[, , site] <- ifelse(lifeExpNL < cureTime[site], lifeExpNL, cureTime[site])
  # 2 months for diagnosis and management
  state_diag[, , site] <- (2 / 12 * DW[1, site])
  state_ctrl[, , site] <- (cappedCureTime[, , site] - 2 / 12) * DW[2, site]
  survSexAgeSite[, , site] <- (state_diag[, , site] + state_ctrl[, , site])
  # define remaining LE after cure achieved
  RLE[, , site] <- (lifeExpNL - cappedCureTime[, , site])
}
# Optionally include YLD due to infertility (from hysterectomy) in <40 N_YEARS (dw=0.18) and 40-49 N_YEARS (dw=0.10) only:
# We assume (from NKR site, rel. survival option), that 63% of all tumours are pre-stage 2B (based on 2010-2012 figures)
# and that 15% of the early-stage tumours result in infertility, despite fertility-sparing treatment (Plante et al., 2011)
survSexAgeSite[2, 1:8, CE] <- survSexAgeSite[2, 1:8, CE] + ((0.37 + (0.63 * 0.15)) * (RLE[2, 1:8, CE] * 0.18))
survSexAgeSite[2, 9:10, CE] <- survSexAgeSite[2, 9:10, CE] + ((0.37 + (0.63 * 0.15)) * (RLE[2, 9:10, CE] * 0.10))


# Define DWxDDSexAgeSite as sum of surv and nonsurv DWxdd values, weighted by CFR (which is age-independent)
for (g in 1:2) {
  for (s in 1:N_SITES) {
    DWxDDSexAgeSite[g, 1:N_AGE_GROUPS, s] <- (cfrSexSite[g, s] * nonsurvSexAgeSite[g, 1:N_AGE_GROUPS, s]) + ((1 - cfrSexSite[g, s]) * survSexAgeSite[g, 1:N_AGE_GROUPS, s])
  }
}


## Following is needed *ONLY* for calc'ing cancer burden using age-aggregated inc data (so Poisson error gets INCLUDED in estimate).
# Weighted by distribution over age, itself calculating based on entire study period
meanYrsLost_allAges <- array(NA, dim = c(2, N_SITES))
DWxDDSexAgeSite_allAges <- array(NA, dim = c(2, N_SITES))
for (g in 1:2) {
  for (site in 1:N_SITES) {
    DWxDDSexAgeSite_allAges[g, site] <- sum(DWxDDSexAgeSite[g, , site] * apply(inc[g, , 1:N_YEARS, site], 1, sum)) / sum(inc[g, , 1:N_YEARS, site])
    meanYrsLost_allAges[g, site] <- sum(meanYrsLost[g, , site] * apply(inc[g, , 1:N_YEARS, site], 1, sum)) / sum(inc[g, , 1:N_YEARS, site])
  }
}


## Encode HPV type distribution, by category & site; assume equal for both sexes (almost no data!),
# and constant over time, also no suitable data)
TD_AW <- c((0.09 + 0.026), (0.033 + 0.009 + 0.014 + 0.064 + 0.012), (0.683 + 0.161))
Tot_AW <- sum(TD_AW[1:2])
TypeDistr <- array(0, dim = c(4, N_SITES + 1))
# HPV 16+18
TypeDistr[1, ] <- c(0.785, 0.857, 0.692, 0.916, 0.926, 0.925, 0.856, 0.819, (0.09 + 0.026) / Tot_AW * 0.156)
TypeDistr[2, ] <- c(0.164, 0.143, 0.216, 0.084, 0.050, 0.063, 0.071, 0.100, (0.033 + 0.009 + 0.014 + 0.064 + 0.012) / Tot_AW * 0.156) # HPV 31+33+45+52+58
# HPV 6/11, AW *only*
TypeDistr[3, ] <- c(rep(0, 8), (0.683 + 0.161))
# 'Other' for now defined as (1 - sum of first 2 categories), except for AW
TypeDistr[4, 1:N_SITES] <- (rep(1, (N_SITES)) - apply(TypeDistr[1:2, 1:N_SITES], 2, sum))


### convert reported genital warts to no. cases, taking into account popul. size
# number of years since YEAR_START: indexing of years
gw_min <- genital_warts_data |>
  pull(year) |>
  min()
gw_max <- genital_warts_data |>
  pull(year) |>
  max()
# add one since YEAR_START is year 1
idx_min <- gw_min - YEAR_START + 1
idx_max <- gw_max - YEAR_START + 1
# index from gw_break
idx_gw_min <- 1 # by definition
idx_gw_max <- gw_max - gw_min + 1
# converting:
GWincrate2002_20 <- GWincrate2002_20[, idx_gw_min:idx_gw_max]
GWinc2002_20 <- GWincrate2002_20 / 100000 * populNL_total[, idx_min:idx_max]

## Fit Poisson regression model to 2002-*2011*;
# back-predict 1989-2001 *only*; fit a 2nd Poisson model to 2012-CURRENTYEAR as
# breakpoint visible

#### 1st model - back-predict earlier years

# by definition gw_min has index 1
gw_break <- 2011
idx_gw_break <- gw_break - gw_min + 1

# index from YEAR_START
idx_break <- gw_break - YEAR_START + 1

# initialize arrays
predGWincrate_male <- rep(0, N_YEARS)
predGWincrate_female <- rep(0, N_YEARS)
inc_gw <- array(0, dim = c(N_SEX, N_AGE_GROUPS, N_YEARS))

tofit <- data.frame(
  GWincmale = GWinc2002_20[1, idx_gw_min:idx_gw_break],
  GWincfemale = GWinc2002_20[2, idx_gw_min:idx_gw_break],
  populmale = populNL_total[1, idx_min:idx_break],
  populfemale = populNL_total[2, idx_min:idx_break],
  years = idx_min:idx_break
)

malefit <- glm(GWincmale ~ 1 + years + offset(log(populmale)), family = poisson(link = "log"), data = tofit)
femalefit <- glm(GWincfemale ~ 1 + years + offset(log(populfemale)), family = poisson(link = "log"), data = tofit)

topred <- data.frame(
  GWincmale = c(rep(NA, idx_min - 1), GWinc2002_20[1, idx_gw_min:idx_gw_break]),
  GWincfemale = c(rep(NA, idx_min - 1), GWinc2002_20[2, idx_gw_min:idx_gw_break]),
  populmale = populNL_total[1, 1:idx_break],
  populfemale = populNL_total[2, 1:idx_break],
  years = 1:idx_break
)

predGWincrate_male[1:idx_break] <- predict(malefit, newdata = topred, type = "response") / populNL_total[1, 1:idx_break] * 100000
predGWincrate_female[1:idx_break] <- predict(femalefit, newdata = topred, type = "response") / populNL_total[2, 1:idx_break] * 100000

# 2nd model - fit
tofit <- data.frame(
  GWincmale = GWinc2002_20[1, (idx_gw_break + 1):idx_gw_max],
  GWincfemale = GWinc2002_20[2, (idx_gw_break + 1):idx_gw_max],
  populmale = populNL_total[1, (idx_break + 1):idx_max],
  populfemale = populNL_total[2, (idx_break + 1):idx_max],
  years = (idx_break + 1):idx_max
)

malefit <- glm(GWincmale ~ 1 + years + offset(log(populmale)), family = poisson(link = "log"), data = tofit)
femalefit <- glm(GWincfemale ~ 1 + years + offset(log(populfemale)), family = poisson(link = "log"), data = tofit)

# number of years for which no data is available yet for GW incidence
n_unknown <- YEAR_CALCULATION - gw_max
idx_calculation <- YEAR_CALCULATION - YEAR_START + 1

topred <- data.frame(
  GWincmale = c(GWinc2002_20[1, (idx_gw_break + 1):idx_gw_max], rep(NA, n_unknown)),
  GWincfemale = c(GWinc2002_20[2, (idx_gw_break + 1):idx_gw_max], rep(NA, n_unknown)),
  populmale = populNL_total[1, (idx_break + 1):idx_calculation],
  populfemale = populNL_total[2, (idx_break + 1):idx_calculation],
  years = (idx_break + 1):idx_calculation
)

predGWincrate_male[(idx_break + 1):idx_calculation] <- predict(malefit, newdata = topred, type = "response") / populNL_total[1, (idx_break + 1):idx_calculation] * 100000
predGWincrate_female[(idx_break + 1):idx_calculation] <- predict(femalefit, newdata = topred, type = "response") / populNL_total[2, (idx_break + 1):idx_calculation] * 100000
rm(tofit, malefit, femalefit, topred)


## USE ACTUAL GW inc data for the period 2002-CURRENTYEAR, projections otherwise
#  NB. JAGS back-projects GW inc for period 1989-2001 based on regression model fitted
# to period 2002-2011
inctot_gw <- array(0, dim = c(2, N_YEARS))
inctot_gw[1:2, idx_min:idx_max] <- GWinc2002_20
# IMPUTE NUMBER OF AW cases for 2021-2022 for now
if (n_unknown >= 1) {
  inctot_gw[1, (idx_max + 1):(idx_max + n_unknown)] <- predGWincrate_male[(idx_max + 1):(idx_max + n_unknown)] / 100000 * populNL_total[1, (idx_max + 1):idx_calculation]
  inctot_gw[2, (idx_max + 1):(idx_max + n_unknown)] <- predGWincrate_female[(idx_max + 1):(idx_max + n_unknown)] / 100000 * populNL_total[2, (idx_max + 1):idx_calculation]
}


### fit the JAGS model
dataList <- list(
  N_AGE_GROUPS = N_AGE_GROUPS, # number of (narrow, 5-yr) age-groups
  N_SITES = N_SITES, # number of cancer sites
  M = N_YEARS, # M = end year of period w/ data
  cases.tot = inc.tot, # cancer incidence summed over age, for part of model that includes Poisson error
  dwtdd.tot = DWxDDSexAgeSite_allAges, # these two parameters are pre-weighted by age
  avgN_YEARSlost.tot = meanYrsLost_allAges,
  inc = inc, # sex-, age-, year-, and cancer site-stratified incidence
  cases.tot.CIN23 = inctot_cin23,
  alloc.CIN23 = alloc_cin23,
  cases.tot.GW = round(inctot_gw), # Poisson data must be integer
  pop = populNL,
  pop.tot = populNL_total, # needed for GW & CIN II/III incidence estimation only
  OR.ORO.a = 2.220,
  OR.ORO.b = 5.550,
  avgN_YEARSlost = meanYrsLost, # mean years of life lost; calculated from survival curves
  dwtdd = DWxDDSexAgeSite,
  cfr = cfrSexSite, # case-fatality rate, by sex and cancer site
  HR.ORO.a = 24.21, # adjust CFR for reduced relative risk of ORO & OC site mortality for HPV+
  HR.ORO.b = 27.30,
  HR.OC.a = 3.637,
  HR.OC.b = 7.729,
  pType = TypeDistr, # 4 x (N_SITES+1) array: proportions of each type category
  PAF.a = paf_a, # PAFs can vary by sex, year and site
  PAF.b = paf_b
)

## Init vals for incidence *needed* for Poisson-distrib-cancer cases variant!
# NB. N_AGE_GROUPS-8 refers to 11 agegroups with non-zero GW data
# NB. beta params matrices (ncol) depend on how many sites applicable per sex

# assign inits only to years from 2012 onward
init_totGW <- matrix(
  c(rep(NA, 23), rep(22000, (N_YEARS - 23))),
  byrow = TRUE, nrow = 2, ncol = N_YEARS
)

initsList <- list(
  list(
    inc.tot.m = array(10, dim = c(N_YEARS, 5)),
    beta0.GW = rep(-8, 2), beta1.GW = rep(0.10, 2),
    inc.tot.CIN23 = c(rep(3500, N_YEARS)),
    inc.tot.GW = init_totGW,
    inc.tot.f = array(10, dim = c(N_YEARS, 7)),
    .RNG.name = "base::Mersenne-Twister",
    .RNG.seed = 2
  ),
  list(
    inc.tot.m = array(20, dim = c(N_YEARS, 5)),
    beta0.GW = rep(-9, 2),
    beta1.GW = rep(0.07, 2),
    inc.tot.CIN23 = c(rep(5300, N_YEARS)),
    inc.tot.GW = init_totGW,
    inc.tot.f = array(20, dim = c(N_YEARS, 7)),
    .RNG.name = "base::Mersenne-Twister",
    .RNG.seed = 2
  )
)

parameters <- c("DALY.all", "YLD.all", "YLL.all", "inc.tot.GW")
adaptSteps <- 100 # Number of steps to "tune" the samplers
burnInSteps <- 8000 # Number of steps to "burn-in" the samplers
nChains <- 2 # Number of chains to run
numSavedSteps <- 10000 # Total number of steps in chains to save
thinSteps <- 1 # Number of steps to "thin" (1=keep every step)
nIter <- ceiling((numSavedSteps) / nChains) # Steps per chain


jagsModel <- run.jags("model.jags",
  monitor = parameters,
  data = dataList,
  n.chains = nChains,
  burnin = burnInSteps,
  inits = initsList,
  adapt = adaptSteps,
  thin = thinSteps,
  sample = (nIter)
)

codaSamples <- as.mcmc.list(jagsModel)

# store posterior distribution statistics (percentile)
post_agegroup <- summary(codaSamples)[[2]]

#########
# results
#########

DALYAll_median_95CI <- array(NA, dim = c(2, N_YEARS, 3))

DALYAll_median_95CI[1, , ] <- as.matrix(
  tail(
    post_agegroup[grep("^DALY.all\\[1", dimnames(post_agegroup)[[1]]), ][, c(3, 1, 5)], N_YEARS
  ),
  ncol = 3, nrow = N_YEARS, byrow = TRUE
)
DALYAll_median_95CI[2, , ] <- as.matrix(
  tail(
    post_agegroup[grep("^DALY.all\\[2", dimnames(post_agegroup)[[1]]), ][, c(3, 1, 5)], N_YEARS
  ),
  ncol = 3, nrow = N_YEARS, byrow = TRUE
)
