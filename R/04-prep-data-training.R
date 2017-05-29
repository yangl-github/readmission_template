# run data cleaning pipeline
df = df_train %>% 
        drop_xvars_coded_version() %>% 
        convert_xvars_int_to_char() %>% 
        clean_flags() %>% 
        clean_AdmWard()

# seperate vars into yvar and xvars
id_vars = c("pid", "Stay_Number")
const_vars = names(df)[sapply(df, function(x) length(unique(x)) == 1)]
drop_vars = c("Readmit_to_this_Hospital_28_Days", "Readmit_Within_28_Days", 
              "Medical_Officer_Code_1", "Discharge_Date", "Admission_Date",
              "Discharge_Time", "Admission_Time", 
              "DRG", # too many levels of long strings, cannot use directly
              "Episodes_PDx", # too many levels of long strings
              "srg", # repeat of "SRG"
              "Marital_Status_Code", # has less cnt in the last level than Marital_Status_NHDD so use later
              "Country_of_Birth",
              "Country_of_Birth_SACC", # too many sparse levels
              "Financial_Class_Local", # too many sparse levels
              "Legal_Status_on_Admit", # too many sparse levels
              "Source_of_Referral",    # too many sparse levels
              "Bed_Unit_Type_on_Admission", # too many sparse levels
              "ED_Mode_of_Arrival", # heavy NAs
              "Referred_to_on_Separation", # existence of singular level  
              "Intention_to_readmit", # doctor's opinion as if to readmit, too correlated with outcome
              "LOS", # use LosHours, which also includes the hours
              "Age_Group" # use the continuous version
              # "AdmWard_group", # admission ward
              # "WardDschUnitType", # discharge ward
              )
yvar = "unplanned_readmit_28_Days"
xvars = names(df)[!names(df) %in% c(id_vars, const_vars, drop_vars, yvar)]
is_con = sapply(df[xvars], function(x) class(x) %in% c("integer", "numeric"))
is_cat = sapply(df[xvars], function(x) class(x) %in% c("factor", "character"))
xvars_con = xvars[is_con]
xvars_cat = xvars[is_cat]


# # manually look at each var distribution
# prop.table(table(df[[yvar]]))
# xvar = "Referred_to_on_Separation"
# unique(df[[xvar]])
# f = ypct_in_cat_x(df, yvar)
# f(xvar)
# str(df[xvars])


# subset df with yvar and xvars 
df = df[c(yvar, xvars)]

# clean bad characters
df = clean_bad_chars(df, xvars_cat)

# impute NAs for con xvars
lst = impute_na_with_med(df, xvars_con)
df = lst$df
write_rds(lst$medians, file.path(cleaned_path, "xvars_con_medians.rds"))

# check if most of the duplicates have y = 0, stop if not
dupes_logical = duplicated(df)
if (sum(dupes_logical) > 0) tmp = df[dupes_logical,]
stopifnot(prop.table(table(tmp[[yvar]]))[2] < 0.01)

# dedupe again
if (sum(dupes_logical) > 0) df = df[!dupes_logical,]
# nrow(df)
# str(df)


# save freq count of each categorical xvar as csv file
f = mk_tbl_cat_var(df)
freq_path = file.path(csv_path, "freq")
dir.create(freq_path, showWarnings = F)
invisible(lapply(xvars_cat, function(xvar) 
        write.csv(f(xvar), row.names = T,
                  file.path(freq_path, paste0("freq_", xvar, ".csv"))))
)

# run before exploratory analysis and output report
rmarkdown::render("R/exploratory-analysis.R",
                  output_file = "exploratory-analysis-training-before.pdf",
                  output_dir  = pdf_path)

# bin sparse levels for cat xvars
df = df %>% bin_sparse_lvls()

# run after exploratory analysis and output report
rmarkdown::render("R/exploratory-analysis.R",
                  output_file = "exploratory-analysis-training-after.pdf",
                  output_dir  = pdf_path)
