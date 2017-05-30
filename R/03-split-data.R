# use the last 30 days data as the final test set
df_test = df %>% filter(Admission_Date >= max(Admission_Date) - 30)
# nrow(df_test)
write_rds(df_test, file.path(data_path, "df_test.rds"))

# use the other data as the training set
df_train = df %>% filter(Admission_Date < as.Date("2017-01-01"))
# nrow(df_train)

# Notice this is not a random split, but we'd still like to see the percents of 
# unplanned readmissions are about the same in both the training and test sets.
# We're lucky that they are. If they are not, we'd need to do a random split.
ypct_test = prop.table(table(df_test$unplanned_readmit_28_Days))
ypct_train = prop.table(table(df_train$unplanned_readmit_28_Days))
stopifnot(abs(ypct_test[2] - ypct_train[2]) < 0.05)

