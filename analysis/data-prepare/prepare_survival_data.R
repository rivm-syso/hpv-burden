# Prepare survival data as it is assumed as input for calculate.R
# Survival data from 2006-2015 originally downloaded from NKR website. 
# Original download has been lost. 

# survival data
N_YEAR_SURVIVAL <- 10
surv <- array(0, dim = c(N_SEX, N_AGE_GROUPS, N_YEAR_SURVIVAL, N_SITES))
# location of data
data_dir <- DIR_SURVIVAL_DATA
# The cancer sites
CE <- 1
VU <- 2
VA <- 3
AN <- 4
ORO <- 5
OC <- 6
LA <- 7
PE <- 8

tmp <- read.csv2(file = fs::path(data_dir, "NL_alle_kankers_overleving_agegrp10.csv"), header = FALSE, as.is = TRUE) # assign values in each 10-yr interval to 5-year groups
# Note. finicky code, not robust to future changes in number of age-groups.
s <- 0
surv[1, 1:N_AGE_GROUPS, 1:10, OC] <- as.matrix(rbind(
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12],
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 2, 3:12], tmp[s + 2, 3:12], tmp[s + 3, 3:12], tmp[s + 3, 3:12],
  tmp[s + 4, 3:12], tmp[s + 4, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12]
), ncol = 10, nrow = N_AGE_GROUPS, byrow = T)
surv[2, 1:N_AGE_GROUPS, 1:10, OC] <- surv[1, 1:N_AGE_GROUPS, 1:10, OC]
s <- 5
surv[1, 1:N_AGE_GROUPS, 1:10, ORO] <- as.matrix(rbind(
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12],
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 2, 3:12], tmp[s + 2, 3:12], tmp[s + 3, 3:12], tmp[s + 3, 3:12],
  tmp[s + 4, 3:12], tmp[s + 4, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12]
), ncol = 10, nrow = N_AGE_GROUPS, byrow = T)
surv[2, 1:N_AGE_GROUPS, 1:10, ORO] <- surv[1, 1:N_AGE_GROUPS, 1:10, ORO] # THIS IS OROPHARYNX SITE (FROM NKR WEBTOOL!)
s <- 10
surv[1, 1:N_AGE_GROUPS, 1:10, LA] <- as.matrix(rbind(
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12],
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 2, 3:12], tmp[s + 2, 3:12], tmp[s + 3, 3:12], tmp[s + 3, 3:12],
  tmp[s + 4, 3:12], tmp[s + 4, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12]
), ncol = 10, nrow = N_AGE_GROUPS, byrow = T)
surv[2, 1:N_AGE_GROUPS, 1:10, LA] <- surv[1, 1:N_AGE_GROUPS, 1:10, LA]
s <- 15
surv[1, 1:N_AGE_GROUPS, 1:10, PE] <- as.matrix(rbind(
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12],
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 2, 3:12], tmp[s + 2, 3:12], tmp[s + 3, 3:12], tmp[s + 3, 3:12],
  tmp[s + 4, 3:12], tmp[s + 4, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12]
), ncol = 10, nrow = N_AGE_GROUPS, byrow = T)
surv[2, 1:N_AGE_GROUPS, 1:10, PE] <- 0
s <- 20
surv[1, 1:N_AGE_GROUPS, 1:10, AN] <- as.matrix(rbind(
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12],
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 2, 3:12], tmp[s + 2, 3:12], tmp[s + 3, 3:12], tmp[s + 3, 3:12],
  tmp[s + 4, 3:12], tmp[s + 4, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12]
), ncol = 10, nrow = N_AGE_GROUPS, byrow = T)
surv[2, 1:N_AGE_GROUPS, 1:10, AN] <- surv[1, 1:N_AGE_GROUPS, 1:10, AN]
surv[1, 1:N_AGE_GROUPS, 1:10, VU] <- 0
s <- 25
surv[2, 1:N_AGE_GROUPS, 1:10, VU] <- as.matrix(rbind(
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12],
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 2, 3:12], tmp[s + 2, 3:12], tmp[s + 3, 3:12], tmp[s + 3, 3:12],
  tmp[s + 4, 3:12], tmp[s + 4, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12]
), ncol = 10, nrow = N_AGE_GROUPS, byrow = T)
surv[1, 1:N_AGE_GROUPS, 1:10, VA] <- 0
s <- 30
surv[2, 1:N_AGE_GROUPS, 1:10, VA] <- as.matrix(rbind(
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12],
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 2, 3:12], tmp[s + 2, 3:12], tmp[s + 3, 3:12], tmp[s + 3, 3:12],
  tmp[s + 4, 3:12], tmp[s + 4, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12]
), ncol = 10, nrow = N_AGE_GROUPS, byrow = T)
surv[1, 1:N_AGE_GROUPS, 1:10, CE] <- 0
s <- 35
surv[2, 1:N_AGE_GROUPS, 1:10, CE] <- as.matrix(rbind(
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12],
  tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 1, 3:12], tmp[s + 2, 3:12], tmp[s + 2, 3:12], tmp[s + 3, 3:12], tmp[s + 3, 3:12],
  tmp[s + 4, 3:12], tmp[s + 4, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12], tmp[s + 5, 3:12]
), ncol = 10, nrow = N_AGE_GROUPS, byrow = T)
mode(surv) <- "numeric"
