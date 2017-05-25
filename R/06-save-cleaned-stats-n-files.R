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
write_rds(df, file.path(cleaned_path, "df.rds"))
