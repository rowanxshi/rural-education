load("../data/time_series.Rdata")

print(ggplot(educ_attain[sample != "urban9"], aes(x = sample, y = p, fill = educ_attain)) + ggtitle("educational attainment") + labs(fill = "education")  + geom_bar(stat = "identity") + facet_wrap(~ year) + labs(x = "", y = "") + scale_x_discrete(labels = c("all", "rural", "urban")) + scale_fill_manual(values = graphing_palette[1:4]))
print(ggplot(d_educ_attain[sample != "urban9" & !is.na(d_share)], aes(x = sample, y = d_share, fill = educ_attain)) + geom_bar(stat = "identity", position = position_dodge()) + facet_wrap(~ end_year) + ggtitle("change in educational attainment shares") + labs(x = "", y = "", fill = "education") + scale_x_discrete(labels = c("all", "rural", "urban")) + scale_fill_manual(values = graphing_palette[1:4]))
