bin_sparse_lvls = function(df) {
        # Combines sparse levels of each cat xvar in a given data set.
        #       Combining is based on similarity of the percents of y=1 at each level.
        #
        # df: data frame
        
        lst_of_lumps = list(c("PSYC", "PPSY"),
                            c("GP", "OBS"),
                            c("GER", "NEU"),
                            c("MON", "GES"),
                            c("DMT", "ANA", "URO"),
                            c("REN", "HAE"))
        for (lump in lst_of_lumps) 
                df$Medical_Officer_1_Unit[df$Medical_Officer_1_Unit %in% lump] = 
                        paste(lump, collapse="_")
        
        lst_of_lumps = list(c("M203", "N210"))
        for (lump in lst_of_lumps) 
                df$Facility_ID[df$Facility_ID %in% lump] = paste(lump, collapse="_")
        
        lst_of_lumps = list(c("BA", "MC"))
        for (lump in lst_of_lumps) 
                df$AdmWard_group[df$AdmWard_group %in% lump] = paste(lump, collapse="_")
        
        lst_of_lumps = list(c("46", "87"), c("60", "NA"))
        for (lump in lst_of_lumps) 
                df$WardDschUnitType[df$WardDschUnitType %in% lump] = 
                paste(lump, collapse="_")
        
        
        lst_of_lumps = list(c("11-Transfer to Palliative Care Unit", 
                              "3-Transfer to Residential Aged Care Facility"),
                            c("7-Death without Autopsy", "6-Death with Autopsy", "NA")
        )
        df$Mode_of_Separation[df$Mode_of_Separation %in% lst_of_lumps[[1]]] = "11_3"
        df$Mode_of_Separation[df$Mode_of_Separation %in% lst_of_lumps[[2]]] = "Death or NA"
        
        
        lst_of_lumps = list(c("54 Non Subspecialty Surgery", "84 Rehabilitation"),
                            c("86 Palliative Care", "50 Ophthalmology"),
                            c("23 Renal Dialysis", "85 Psychogeriatric Care"),
                            c("99 Unallocated", "NA"))
        for (lump in lst_of_lumps) 
                df$SRG[df$SRG %in% lump] = paste(lump, collapse="_")
        
        
        lst_of_lumps = list(c("33", "NA"))
        for (lump in lst_of_lumps) 
                df$Payment_Status_on_Separation[df$Payment_Status_on_Separation %in% lump] = 
                paste(lump, collapse="_")
        
        
        lst_of_lumps = list(c("2", "NA"))
        for (lump in lst_of_lumps) 
                df$Financial_Program[df$Financial_Program %in% lump] = 
                paste(lump, collapse="_")
        
        
        lst_of_lumps = list(c("3", "NA"))
        for (lump in lst_of_lumps) 
                df$Medicare_Eligibilty_Status[df$Medicare_Eligibilty_Status %in% lump] = 
                paste(lump, collapse="_")
        
        
        df        
}

