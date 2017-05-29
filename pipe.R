rm(list = ls())

source("R/00-user-input.R")
source("R/01-set-up.R")
source("R/02-drop-inaccurate-records-n-dedupe.R")
source("R/03-split-data.R")


t0 = Sys.time()

## BEGIN Train Model ##

source("R/04-prep-data-training.R")
source("R/05-save-data-cleaned.R")
# source("R/07-train.R")

## END Train Model ##

(dur = Sys.time() - t0)




t0 = Sys.time()

## BEGIN Scoring New Patients ##

source("R/score-new-patients/01-prep-data.R")
# source("R/09-get-tree-probs-classlabels-from-ruleset.R")
# source("R/10-score-patients-n-output-scoring-pathways.R")


## END Scoring New Patients ##

(dur = Sys.time() - t0)
