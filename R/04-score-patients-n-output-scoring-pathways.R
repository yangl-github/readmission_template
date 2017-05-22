# read patients data
df_patients = read_csv(file.path(data_path, fname_patients))
pids = df_patients$pid
# str(df_patients, max.level = 1)


# separate rules by split variables
lst = split(df_rules %>% select(leaf, variable, variable_level), 
            df_rules$variable)
lst_of_rules = lapply(names(lst), function(var) {
        elt = lst[[var]]
        elt$variable = NULL
        names(elt) = gsub("variable_level", var, names(elt))
        if (var %in% c("Age", "LOS")) elt[[var]] = as.integer(elt[[var]])
        elt
})
names(lst_of_rules) = names(lst)

# # see the difference between lst and lst_of_rules
# lst[[1]]
# lst_of_rules[[1]]


# classify/match patients based on each split variable independently
lst_of_matches = lapply(names(lst_of_rules), function(var) {
        left_join(df_patients, lst_of_rules[[var]])        
})
names(lst_of_matches) = names(lst_of_rules)


# score patients and find the correct scoring pathway
# lst_of_df_scored = lapply(pids, function(i) {
lst_of_df_scored = foreach(i = pids) %dopar% {        
        # i = 35
        # cat(i, "\n")
        
        # find all possible pathways
        leaves = lapply(lst_of_matches, function(elt) elt %>% 
                                filter(pid == i) %>% select(leaf) %>% unlist()
                        ) %>% unlist() %>% sort()
        df_leaves = data.frame(leaf = leaves,
                               var = gsub("\\.leaf[0-9]*", "", names(leaves)))
        pathways = df_leaves %>% group_by(leaf) %>% 
                summarise(vars_ordered_alphabetically = 
                                  paste(sort(unique(var)), collapse=", "))
        
        # identify the correct one from all possible pathways
        pathway_correct = inner_join(tree, pathways)
        
        # look up its class prob and label
        if (nrow(pathway_correct) == 0) {
                df_scored = data.frame(leaf = NA, 
                                       vars_ordered_by_split_order = NA,
                                       prob = NA, class_label = NA)
        } else {
                df_scored = left_join(pathway_correct, scorecard) %>% 
                        select(-vars_ordered_alphabetically)
        }
        
        # append pid and return
        cbind(pid = i, df_scored)
}

# rowbind into a big data frame
df_scored = bind_rows(lst_of_df_scored)

# append to patient data and save
stopifnot(nrow(df_scored) == nrow(df_patients))
scored_patients = left_join(df_patients, df_scored)
write_csv(scored_patients, file.path(output_path, "scored_patients.csv"))


