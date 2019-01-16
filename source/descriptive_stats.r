load("../data/censes.Rdata")
load("../out/run_report.Rdata")

# Data quality tests
count_missing <- function(census_sample, variables) {
    sapply(variables, function(variable) census_sample[is.na(get(variable)), .N])
}
run_report <- add_to_run_report(run_report, lapply(split(censes, censes$year), function(census_sample) count_missing(census_sample, names(census_sample))), "Censes missing values table")

# Apply educational categories
censes[age > 5 & is.na(educhn), .N == 0] %>% assertthat::assert_that()
censes[age > 5, c("educ_attain", "educ_age") := .(cut(educhn, breaks = c(-Inf, 206, 303, 313, Inf), right = FALSE, labels = c("none", "prim", "middle", "high"), ordered_result = TRUE), cut(age, breaks = c(5, 12, 14, 18, Inf), right = FALSE, labels = c("prim", "middle", "high", "later"), ordered_result = TRUE))]
save(censes, file = "../data/censes.Rdata")

# Aggregate
aggregated <- censes[age > 5, .(N = sum(perwt), all = TRUE), by = .(year, sex, urban, educ_attain, educ_age, school, geo2_hn)]
## recode the school variable
aggregated[, school := ifelse(school == 9, NA, school == 1)]

# Time series comparisons
calc_proportions <- function(small_group_vars, total_group_vars) {
    proportions_key <- c("sample", small_group_vars)
    select_vars <- c(proportions_key, "year", "p", "N")
    calc_proportions_over_samples <- function(sample_vars) {
        aggregated[, .(N = sum(N)), by = c("year", sample_vars, small_group_vars)][, c("p", "sample") := .(100*N/sum(N), paste0(sample_vars, get(sample_vars))), by = c("year", sample_vars, total_group_vars)][, ..select_vars]
    }
    proportions <- lapply(c("all", "urban"), calc_proportions_over_samples) %>% rbindlist()
    setkeyv(proportions, c(proportions_key, "year"))

    return(proportions)
}
educ_attain <- calc_proportions("educ_attain", NULL)
d_educ_attain <- educ_attain[, .(d_share = p - shift(p), end_year = year), by = .(sample, educ_attain)]
d_educ_attain[is.na(d_share) & sample != "urban9", all(end_year == 1974)] %>% assertthat::assert_that()

educ_attend <- calc_proportions(c("educ_age", "school"), "educ_age")
d_educ_attend <- educ_attend[, .(d_share = p - shift(p), end_year = year), by = .(sample, educ_age, school)]
d_educ_attend[is.na(d_share) & sample != "urban9", all(end_year == 1974)] %>% assertthat::assert_that()

graphing_palette <- c("#D55E00", "#E69F00", "#56B4E9", "#009E73", "#0072B2", "#CC79A7")
save(educ_attain, d_educ_attain, educ_attend, d_educ_attend, graphing_palette, file = "../data/time_series.Rdata")

# Geo cross sections: establish geographic variation
educ_attend_muni <- calc_proportions(c("geo2_hn", "educ_age", "school"), c("geo2_hn", "educ_age"))
add_to_run_report <- add_to_run_report(run_report, tapply(educ_attend_muni[is.na(school)]$p, educ_attend_muni[is.na(school)]$sample, summary), "Distribution of missing school attendance percentages")
## drop municipalities with over 5% missing schooling data
educ_attend_muni[is.na(school) & p > 5, drop := 1]
educ_attend_muni <- educ_attend_muni[order(sample, geo2_hn, drop), drop := first(drop), by = .(sample, geo2_hn)][is.na(drop) & !is.na(school)][, drop := NULL]
## fill in school status for each sample-geo2_hn-educ_age-year combination
educ_attend_muni <- educ_attend_muni %>% dcast(sample + geo2_hn + educ_age + year ~ school, value.var = c("p", "N"), fill = 0) %>% melt(measure = patterns("^p", "^N"), value.name = c("p", "N"), variable.factor = FALSE)
educ_attend_muni[, c("school", "variable") := .(variable == "2", NULL)]
setkeyv(educ_attend_muni, c("sample", "geo2_hn", "educ_age", "school", "year"))
# create changes in shares
d_educ_attend_muni <- educ_attend_muni[, .(d_share = p - shift(p), end_year = year), by = .(sample, geo2_hn, educ_age, school)]
d_educ_attend_muni_sd <- sapply(split(d_educ_attend_muni[sample == "allTRUE" & !is.na(d_share) & school == TRUE], d_educ_attend_muni[sample == "allTRUE" & !is.na(d_share) & school == TRUE, .(educ_age, end_year)]), function(dt) sd(dt$d_share)) %>% matrix(nrow = 4, ncol = 2)
rownames(d_educ_attend_muni_sd) <- levels(censes$educ_age)
colnames(d_educ_attend_muni_sd) <- unique(censes$year)[-1]
save(d_educ_attend_muni, file = "../data/d_educ_attend_muni.Rdata")
save(d_educ_attend_muni_sd, file = "../out/d_educ_attend_muni_sd.Rdata")

## calculate rural-ness of each muni
muni_ruralness <- aggregated[, .(N = sum(N)), by = .(year, geo2_hn, urban)][, .(ruralness = N/sum(N), urban = urban), by = .(year, geo2_hn)][urban == 1][, urban := NULL]
names(muni_ruralness) <- c("year", "muni", "ruralness")
save(muni_ruralness, file = "../data/muni_ruralness.Rdata")

save(run_report, add_to_run_report, file = "../out/run_report.Rdata")

rm(list=ls())
