load("../data/censes.Rdata")
load("../data/bp_to_muni.Rdata")
load("../data/d_educ_attend_muni.Rdata")
load("../data/muni_ruralness.Rdata")

# select sample: age range must be after 21 (after university, if completed) and before 45 ("changes" period 1974-1988 is not after schooling period)
sample <- censes[year == 2001 & urban < 9 & educ_age == "later" & age < 45 & yrschool < 90 & nativity < 9]

# merge in instruments
instruments <- d_educ_attend_muni[sample == "allTRUE" & end_year == 1988 & !is.na(d_share) & school == TRUE] %>% dcast(geo2_hn ~ educ_age, value.var = "d_share")
names(instruments) <- c("muni", names(instruments)[-1])
sample <- instruments[bp_to_muni[sample, on = c(bp = "bplhn2")], on = "muni"][!is.na(prim)]
# merge in ruralness
sample <- muni_ruralness[year == 1988][sample, on = "muni"]
# controls: age, age^2, sex, maritial status, maybe their interaction, nativity; create variables
sample[, c("rural", "female", "married", "native") := lapply(list(urban == 1, sex == 2, marst == 2, nativity == 1), as.integer)]

# save
sample <- sample[, .(perwt, age, female, married, native, live_urban = 1 - rural, bp_prim = prim, bp_middle = middle, bp_high = high, bp_later = later, bp_ruralness = ruralness, school_years = yrschool, bp_muni = muni)]
save(sample, file = "../data/sample.Rdata")
fwrite(sample, file = "../data/sample.csv")
