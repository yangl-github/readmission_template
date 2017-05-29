# set paths and read data 
df = read_rds(file.path(data_path, "df_test.rds"))
yvar = read_rds(file.path(cleaned_path, "yvar.rds"))
xvars = read_rds(file.path(cleaned_path, "xvars.rds"))
xvars_cat = read_rds(file.path(cleaned_path, "xvars_cat.rds"))
xvars_con = read_rds(file.path(cleaned_path, "xvars_con.rds"))
medians   = read_rds(file.path(cleaned_path, "xvars_con_medians.rds"))

# run data cleaning pipeline
df = df %>% 
        drop_xvars_coded_version() %>% 
        convert_xvars_int_to_char() %>% 
        clean_flags() %>% 
        clean_AdmWard()

# subset df with yvar and xvars 
df = df[c(yvar, xvars)]

# clean bad characters in the character xvars
df = clean_bad_chars(df, xvars_cat)

# impute NAs for con xvars
lst = impute_na_with_med(df, xvars_con, replacement = medians)
df = lst$df

# bin sparse levels for cat xvars
df = df %>% bin_sparse_lvls()

# run exploratory analysis and output report
rmarkdown::render("R/exploratory-analysis.R",
                  output_file = "exploratory-analysis-new-patients.pdf",
                  output_dir  = pdf_path)
