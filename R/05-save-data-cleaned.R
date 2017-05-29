# delete all files in freq_path
unlink(file.path(freq_path, list.files(freq_path)))

# save freq count of each categorical xvar as csv file again
f = mk_tbl_cat_var(df)
freq_path = file.path(csv_path, "freq")
dir.create(freq_path, showWarnings = F)
invisible(lapply(xvars_cat, function(xvar) 
        write.csv(f(xvar), row.names = T,
                  file.path(freq_path, paste0("freq_", xvar, ".csv"))))
)

# save for later use
write_rds(df, file.path(cleaned_path, "df_train.rds"))
write_rds(yvar, file.path(cleaned_path, "yvar.rds"))
write_rds(xvars, file.path(cleaned_path, "xvars.rds"))
write_rds(xvars_con, file.path(cleaned_path, "xvars_con.rds"))
write_rds(xvars_cat, file.path(cleaned_path, "xvars_cat.rds"))
