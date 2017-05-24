# read data
df = read_csv(file.path(data_path, fname_raw), 
              na = c("", "NA", "NO VALUE", "Unknown", "Unknown \r\r\n"))
names(df)[1] = "pid"
names(df) = gsub(" ", "_", names(df))
# str(df)

## BEGIN Dedupe ##

# dedupe based on all vars but the ID vars, can take some time
dupes_logical = duplicated(df %>% select(-pid, -Stay_Number))
if (sum(dupes_logical) > 0) df = df[!dupes_logical,]

# # same patient can have multiple rows as seen by same Stay_Number, LOS and yvar
# sort(table(df$Stay_Number), decreasing = T)
# tmp = df %>% filter(Stay_Number == 80644620)
# View(tmp)
# length(unique(tmp$LOS)) == 1
# length(unique(tmp$unplanned_readmit_28_Days)) == 1

# for those duplicated patients, remove all but the first row
dupes_logical = duplicated(df %>% select(Stay_Number, LOS, unplanned_readmit_28_Days))
dupes_logical2 = duplicated(df %>% select(Stay_Number, LOS))
dupes_logical3 = duplicated(df %>% select(Stay_Number))
stopifnot(sum(dupes_logical) == sum(dupes_logical2))
stopifnot(sum(dupes_logical) == sum(dupes_logical3))
if (sum(dupes_logical) > 0) df = df[!dupes_logical,]
stopifnot(length(unique(df$Stay_Number)) == nrow(df))

## END Dedupe ##


## BEGIN clean ##

# some vars have a coded version (integer codes) and actual version 
# (meaningful word descriptions), we drop the coded version and use the
# meaningful verison
Desc_vars = grep("Desc|Description$", names(df), value = T)
unDesc_vars = gsub("_?Description|_?Desc$", "", Desc_vars)
df = df %>% select_(.dots = paste("-", unDesc_vars[unDesc_vars %in% names(df)]))

# simplify these meaningful versioned varnames by removing "_Desc" and
# its variants
names(df)[names(df) %in% Desc_vars] = unDesc_vars

# clean specific vars
df = df %>% mutate(
        # remove white spaces
        Source_of_Referral = gsub("\\s+$", "", Source_of_Referral),
        
        # convert 0/1 vars to characters of values N/Y
        Sepsis_Flag = ifelse(Sepsis_Flag == 1, "Y", "N"),
        CC_Flag = ifelse(CC_Flag == 1, "Y", "N"),
        Renal_Flag = ifelse(Renal_Flag == 1, "Y", "N"),
        
        # convert cat vars (coded as integers) to characters
        Bed_Unit_Type_on_Admission = as.character(Bed_Unit_Type_on_Admission),
        WardDschUnitType = as.character(WardDschUnitType),
        Referred_to_on_Separation = as.character(Referred_to_on_Separation),
        Marital_Status_Code = as.character(Marital_Status_Code),
        Marital_Status_NHDD = as.character(Marital_Status_NHDD),
        Country_of_Birth = as.character(Country_of_Birth),
        Country_of_Birth_SACC = as.character(Country_of_Birth_SACC),
        Payment_Status_on_Separation = as.character(Payment_Status_on_Separation),
        Financial_Program = as.character(Financial_Program),
        Medicare_Eligibilty_Status = as.character(Medicare_Eligibilty_Status),
        Intention_to_readmit = as.character(Intention_to_readmit)
        )

## END clean ##

# seperate vars into yvar and xvars
id_vars = c("pid", "Stay_Number")
drop_vars = c("Readmit_to_this_Hospital_28_Days", "Readmit_Within_28_Days", 
              "Medical_Officer_Code_1", "Discharge_Date", "Admission_Date",
              "Discharge_Time", "Admission_Time",
              "DRG", # too many levels of long strings
              "Episodes_PDx", # too many levels of long strings
              "srg", # repeat of "SRG"
              "LOS"
              )
yvar = "unplanned_readmit_28_Days"
xvars = names(df)[!names(df) %in% c(id_vars, drop_vars, yvar)]
# xvars_con = c("Age", "LOS")
# xvars_cat = xvars[!xvars %in% xvars_con]


# # manually look at each var distribution
# prop.table(table(df[[yvar]]))
# xvar = "Referred_to_on_Separation"
# unique(df[[xvar]])
# f = ypct_in_cat_x(df, yvar)
# f(xvar)
# str(df)


# subset df with yvar and xvars 
df = df[c(yvar, xvars)]
dupes_logical = duplicated(df)

# check if most of the duplicates have y = 0, stop if not
if (sum(dupes_logical) > 0) tmp = df[dupes_logical,]
stopifnot(prop.table(table(tmp[[yvar]]))[2] < 0.01)

# dedupe again
if (sum(duplicated(df)) > 0) df = df[!dupes_logical,]
# nrow(df)
# str(df)
