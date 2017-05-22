# install packages from cran
cran_pkgs = c("readr", "tidyr", "dplyr",
               "doParallel", ## used to replace doMC
              # "doMC", 
              "foreach")
for (pkg in cran_pkgs) {
        if (!pkg %in% installed.packages()) {
                cat(paste(pkg, "missing, will attempt to install\n"))
                install.packages(pkg)
        } else cat(paste(pkg, "installed OK\n"))
}

cat("### All required packages installed ###")

# load packages
lapply(cran_pkgs, FUN=library, character.only = TRUE)

# set options
options(scipen = 999)
ncores = parallel::detectCores() - 1 # same value as what registerDoMC() gives
#registerDoMC(ncores)
cl <- parallel::makeCluster(ncores) ## used to replace registerDoMC(ncores)
doParallel::registerDoParallel(cl) ## ## used to replace registerDoMC(ncores)
cat("Number of workers registered:", ncores, "\n\n")


# set paths and file names
data_path = "data"
fname_rules = "RuleSet.csv"
fname_patients = "NewPatientsRecords(last 30 days).csv"
output_path = "output"
dir.create(output_path, showWarnings = F)

