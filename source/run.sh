Rscript ./r_master.r
stata -b do analysis
Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc")' -e 'rmarkdown::render("../out/summary.Rmd")'
