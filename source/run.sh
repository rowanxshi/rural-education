Rscript ./r_master.r
stata -b do analysis
Rscript -e 'rmarkdown::render("../out/summary.Rmd", output_dir="../", output_format = "pdf_document")'
