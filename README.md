# Investigating whether education results in migration from rural to urban areas

This project is quick look at the above question, using Honduras census data. A PDF report containing results is provided at `./summary.pdf`.

## Replicating

All code is in `./source/`, all data (both original and outputted) is in `./data/`, and all output files are in `./out/`.

Original data is downloaded from IPUMS-international, and therefore cannot be disseminated here. All microdata has been removed from the public project. However, the codebook is provided at `./ipumsi_00002.txt` for easy replication. The downloaded IPUMS data should be placed in the `./data/` directory.

After downloading, just run the `./source/run.sh` file and look for the rendered report in `./summary.pdf`.

## Required Packages

R:

- `data.table`
- `tidyverse` (specifically `magrittr`, `ggplot2`, and `rmarkdown`)

Stata:

- `esttab`
