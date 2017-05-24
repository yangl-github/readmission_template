# install packages from cran
cran_pkgs = c("readr", "tidyr", "dplyr", "knitr", "rmarkdown",
              "foreach", "doParallel")
for (pkg in cran_pkgs) {
        if (!pkg %in% installed.packages()) {
                cat(paste(pkg, "missing, will attempt to install\n"))
                install.packages(pkg)
        } else cat(paste(pkg, "installed OK\n"))
}

github_pkgs = c("ezplot") # "scales", "ggplot2", "ggthemes", 
for (pkg in github_pkgs) {
        if (!pkg %in% installed.packages()) {
                cat(paste(pkg, "missing, will attempt to install\n"))
                # if (pkg %in% c("scales", "ggplot2"))
                #         devtools::install_github(paste0("hadley/", pkg))
                # if (pkg == "ggthemes")
                #         devtools::install_github(paste0("jrnold/", pkg))
                if (pkg == "ezplot")
                        devtools::install_github(paste0("gmlang/", pkg))
        } else cat(paste(pkg, "installed OK\n"))
}

cat("### All required packages installed ### \n\n")

# load packages
lapply(c(cran_pkgs, github_pkgs), FUN=library, character.only = TRUE)

# set options
options(scipen = 999) # disable scientific notation
ncores = parallel::detectCores() / 2 # same value as what registerDoMC() gives
registerDoParallel(cores = ncores)
cat("Number of workers registered:", ncores, "\n\n")

# set paths
data_path = "data"
helper_path = "R/helper"
output_path = "output"
csv_path = file.path(output_path, "csv")
pdf_path = file.path(output_path, "pdf")
dir.create(csv_path, showWarnings = F, recursive = T)
dir.create(pdf_path, showWarnings = F, recursive = T)

# source helper functions
for (fname in list.files(helper_path)) source(file.path(helper_path, fname))
