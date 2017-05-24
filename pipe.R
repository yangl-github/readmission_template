rm(list = ls())

t0 = Sys.time()

source("R/00-user-input.R")
source("R/01-set-up.R")
source("R/02-data-sanity-check.R")

# help data scientist understand the data and choose modeling strategies 
# NO need to run in production
rmarkdown::render("R/03-exploratory-analysis.R",
                  output_file = "03-exploratory-analysis.pdf",
                  output_dir  = pdf_path)



# source("R/09-get-tree-probs-classlabels-from-ruleset.R")
# source("R/10-score-patients-n-output-scoring-pathways.R")

dur = Sys.time() - t0
print(dur)
