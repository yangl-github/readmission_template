rm(list = ls())

t0 = Sys.time()

source("R/01-set-up.R")
source("R/02-get-tree-probs-classlabels-from-ruleset.R")
source("R/04-score-patients-n-output-scoring-pathways.R")

dur = Sys.time() - t0
print(dur)
