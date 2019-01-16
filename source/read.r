ddi <- read_ipums_ddi("ipumsi_00002.xml")
censes <- read_ipums_micro(ddi)

names(censes) <- tolower(names(censes))
setDT(censes)

save(censes, file = "../data/censes.Rdata")

rm(list=ls())
