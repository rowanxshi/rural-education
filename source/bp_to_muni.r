load("../data/censes.Rdata")
load("../out/run_report.Rdata")

# extract values and labels from IPUMS-provided attributes: variables of interest are bplhn2 (detailed "level 2" birthplace) and geo2_hn (detailed "level 2" current living area)
create_dict <- function(variable) {
    label_vector <- attributes(variable)$labels
    labels <- names(label_vector) %>% iconv(from = "UTF-8", to = "ASCII//TRANSLIT")
    dict <- as.data.table(list(label = labels))
    dict[, value := as.vector(label_vector)]
    return(dict)
}
bp <- create_dict(censes$bplhn2)
muni <- create_dict(censes$geo2_hn)
bp <- bp[!grep("unk", label, ignore.case = TRUE)] # drop all unknowns
muni <- muni[!grep("unk", label, ignore.case = TRUE)]

# assign in course "level 1" macro-areas
bp[, big := value %/% 100]
muni[, big := floor(value/1000) %% 100]
bp <- bp[big < 90]
muni <- muni[big < 90]
bp_by_big <- split(bp, bp$big)
muni_by_big <- split(muni, muni$big)

# match within codes for birthplace and current living area within course "level 1" areas
match_bp_to_muni <- function(bp_block, muni_block) {
    bp_block[, .(bp = value, muni = sapply(label, function(pattern) muni_block$value[grep(pattern, muni_block$label)]), n_matches = sapply(label, function(pattern) sum(grepl(pattern, muni_block$label))))]
}
crosswalk <- mapply(match_bp_to_muni, bp_by_big, muni_by_big, SIMPLIFY = FALSE, USE.NAMES = FALSE) %>% rbindlist()

run_report <- add_to_run_report(run_report, table(crosswalk$n_matches), "Municipalities matched to level 2 geographic groups")

# finished crosswalk
bp_to_muni <- crosswalk[n_matches == 1][, .(bp = bp, muni = unlist(muni))]
save(bp_to_muni, file = "../data/bp_to_muni.Rdata")

# save run stats to run report
save(run_report, add_to_run_report, file = "../out/run_report.Rdata")

rm(list=ls())
