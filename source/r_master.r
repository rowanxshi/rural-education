library(ipumsr)
library(data.table)
library(magrittr)
library(ggplot2)

# create run report variable for storing run report outcomes
run_report <- list()
add_to_run_report <- function(run_report, item, title) {
    run_report[[length(run_report) + 1]] <- item
    attr(run_report[[length(run_report)]], "title") <- title
    run_report
}
save(run_report, add_to_run_report, file = "../out/run_report.Rdata")
rm(list=ls())

# read in data from IPUMS format
## input: ../data/ipumsi_00002.xml
## output: ../data/censes.Rdata
source("read.r")

# create concordance between birthplace and geo codes
## input: ../data/censes.Rdata
## output: ../data/bp_to_muni.Rdata
source("bp_to_muni.r")

# do descriptive statistics analysis
## input: ../data/censes.Rdata
## output: ../data/censes.Rdata (updated with education attainment and education age group variables),
##  ../data/time_series.Rdata (with data on educational attainment+attendance and their change over time)
##  ../data/d_educ_attend_muni.Rdata (change in educational attendancee disaggregated at muni-level)
## ../out/d_educ_attend_muni_sd.Rdata (standard deviation across municipalities)
##  ../data/muni_ruralness.Rdata
source("descriptive_stats.r")

# assemble sample for regression analysis
## input: ../data/censes.Rdata, ../data/bp_to_muni.Rdata, ../data/d_educ_attend_muni.Rdata, ../data/muni_ruralness.Rdata
## output: ../data/sample.Rdata, ../data/sample.csv
source("assembly.r")
