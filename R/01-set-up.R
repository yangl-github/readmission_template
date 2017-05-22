# install packages from cran
cran_pkgs = c("readr", "tidyr", "dplyr", "foreach", "doParallel")
for (pkg in cran_pkgs) {
        if (!pkg %in% installed.packages()) {
                cat(paste(pkg, "missing, will attempt to install\n"))
                install.packages(pkg)
        } else cat(paste(pkg, "installed OK\n"))
}

cat("### All required packages installed ### \n\n")

# load packages
lapply(cran_pkgs, FUN=library, character.only = TRUE)

# set options
options(scipen = 999) # disable scientific notation
ncores = parallel::detectCores() / 2 # same value as what registerDoMC() gives
registerDoParallel(cores = ncores)
cat("Number of workers registered:", ncores, "\n\n")

# set paths and file names
data_path = "data"
fname_rules = "RuleSet.csv"
fname_patients = "NewPatientsRecords(last 30 days).csv"
output_path = "output"
dir.create(output_path, showWarnings = F)

