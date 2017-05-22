# read data
df_rules = read_csv(file.path(data_path, fname_rules))
names(df_rules) = tolower(names(df_rules))
# str(df_rules, max.level = 1)

# stop if there're duplicates
stopifnot(sum(duplicated(df_rules)) == 0)

# construct tree from rule set, assuming
#       the values of the "variable" column are listed in the order of split,
#       from first to last.
tree = df_rules %>% group_by(leaf) %>% 
        summarise(
                # use this to represent the tree
                vars_ordered_by_split_order = paste(unique(variable), 
                                                    collapse=", "),
                # use this to filter the correct paths from all possible independent paths 
                vars_ordered_alphabetically = paste(sort(unique(variable)), 
                                                    collapse=", ")
                )

# extract predicted probs and class labels
scorecard = df_rules %>% group_by(leaf) %>% 
        summarise(prob = probability_readmission[1], # use 1st value as all values are the same
                  class_label = ifelse(classification[1] == 2, "Re-admission", 
                                       "No Re-admission"))

