# read data
df_train = read_csv(file.path(data_path, fname_train))
df_test  = read_csv(file.path(data_path, fname_test))

# rbind 
df = bind_rows(df_train, df_test)

# dedupe
dupes_logical = duplicated(df)
if (sum(dupes_logical) > 0) df = df[!dupes_logical,]
stopifnot(sum(duplicated(df)) == 0)

# # sanity check
# str(df, level.max=1)
# table(df$LOS) # what's LOS?
# table(df$Age) # Can Age be 0, < 2, or > 100?
# table(df$unplanned_readmit_28_Days)
# View(df)
# names(df)

# seperate vars into yvar and xvars
yvar = "unplanned_readmit_28_Days"
xvars = grep(yvar, names(df), value = T, invert = T)
xvars_con = c("Age", "LOS")
xvars_cat = xvars[!xvars %in% xvars_con]
        
