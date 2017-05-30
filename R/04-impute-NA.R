# Impute NA so that we can use parallel computation in caret.

# there are a tiny portion of records (or only 1 record) with NA in these vars: 
#       Age, LosHours, Emergency_Status, Marital_Status_NHDD, Sex
# drop them
idx_drop = lapply(c(xvars_con, "Emergency_Status", "Marital_Status_NHDD", "Sex"),
                  function(var) which(is.na(df[[var]]))) %>% unlist()
df = df[-idx_drop, ]

# replace NA in cat. xvars with "Unknown"
for (var in xvars_cat) {
        has_na = is.na(df[[var]])
        if (sum(has_na) > 0) df[[var]][has_na] = "Unknown"
}
        


