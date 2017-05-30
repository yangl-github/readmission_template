drop_xvars_coded_version = function(df) {
        # In the dataset, some vars have both a coded version (integer codes) 
        # and a meaningful version (word descriptions), we drop the coded 
        # version and use the meaningful verison.
        #
        # df: data frame
        
        # drop the coded versions
        Desc_vars = grep("Desc|Description$", names(df), value = T)
        unDesc_vars = gsub("_?Description|_?Desc$", "", Desc_vars)
        df = df %>% select_(.dots = paste("-", unDesc_vars[unDesc_vars %in% names(df)]))
        
        # simplify the varnames of the meaningful versions by removing "_Desc" 
        # and its variants
        names(df)[names(df) %in% Desc_vars] = unDesc_vars
        
        df
}

convert_xvars_int_to_char = function(df) {
        # In the dataset, some categorical vars are coded as integers. Covert
        # them to characters. 
        #
        # df: data frame
        
        df %>% mutate(
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
        
}

clean_flags = function(df) {
        # Converts 0/1 vars to character vars of values N/Y, and
        # converts NA in flag vars to N
        #
        # df: data frame
        within(df, {
                Sepsis_Flag[Sepsis_Flag == 1] = "Y"
                Sepsis_Flag[Sepsis_Flag == 0] = "N"
                Sepsis_Flag[is.na(Sepsis_Flag)] = "N"
                
                CC_Flag[CC_Flag == 1] = "Y"
                CC_Flag[CC_Flag == 0] = "N"
                CC_Flag[is.na(CC_Flag)] = "N"
                
                Renal_Flag[Renal_Flag == 1] = "Y"
                Renal_Flag[Renal_Flag == 0] = "N"
                Renal_Flag[is.na(Renal_Flag)] = "N"
                
                HadPPH[is.na(HadPPH)] = "N"
                HadMH[is.na(HadMH)] = "N"
                CancerCode[is.na(CancerCode)] = "N"
                Complications[is.na(Complications)] = "N"
                Diabetes[is.na(Diabetes)] = "N"
        })
}

clean_AdmWard = function(df) {
        df %>% separate(AdmWard, c("AdmWard_group", "AdmWard_unit"), 
                        sep = "-", extra = "merge") %>% 
                mutate(AdmWard_unit = NULL, AdmWard = NULL)
}

clean_bad_chars = function(df, xvars_cat) {
        # Removes bad characters (leading/trailing white spaces, "&", "\") from 
        #       each cat xvar of a given dataset. Also, replaces NA with "NA".
        #       
        #
        # df: data frame
        # xvars_cat: character vector of varnames of the cat xvars
        
        for (var in xvars_cat) {
                df[[var]] = df[[var]] %>% 
                        str_replace_all(pattern = "&", replace = "and") %>% 
                        str_replace_all(pattern = "\\/.*", replace = "") %>% 
                        str_replace_na() %>% # turn NA into "NA", necessary as NA causes errors in model fitting
                        str_trim()
        }
        
        df
}

impute_na_with_med = function(df, xvars_con, replacement = NULL) {
        # Replaces NAs in each con xvar with it grand median.
        #
        # df: data frame
        # xvars_con: continuous xvar names
        # replacement: numeric vector of medians or means, same length as 
        #       xvars_con, default = NULL

        meds = c()
        for (i in seq_along(xvars_con)) {
                var = xvars_con[i]
                if (is.null(replacement)) med = median(df[[var]], na.rm = T)
                else med = replacement[i]
                
                # replace NA                        
                df[[var]][is.na(df[[var]])] = med
                meds = c(meds, med)
        }
        
        list(df = df, medians = meds)
}

