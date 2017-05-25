# combine sparse categories 

lst_of_lumps = list(c("RON", "PPSY"),
                    c("RAD", "REH", "PSYC", "GER", "CAR"),
                    c("ORT", "ANA", "INT", "VAS", "NEU"),
                    c("MON", "PAE", "ONC", "GP"),
                    c("DMT", "URO"),
                    c("ENS", "DEN"),
                    c("REN", "HAE", "SON"))
for (lump in lst_of_lumps) 
        df$Medical_Officer_1_Unit[df$Medical_Officer_1_Unit %in% lump] = 
                paste(lump, collapse=" | ")


lst_of_lumps = list(c("M711", "L212"),
                    c("L712", "R207"),
                    c("M715", "R719", "M709", "M213", "R711", "R709"),
                    c("R209", "N752", "R202"),
                    c("N704", "R216"),
                    c("R213", "M705", "M704"),
                    c("R708", "N213"),
                    c("R702", "M209"),
                    c("M210", "M706"),
                    c("2698", "N210", "M211", "R706"),
                    c("R710", "M710", "M703", "R713", "M714")
                    )
for (lump in lst_of_lumps) 
        df$Facility_ID[df$Facility_ID %in% lump] = paste(lump, collapse=" | ")

lst_of_lumps = list(c("8 - Psycho-geriatric", "4 - Maintenance Care",
                      "7 - Geriatric Evaluation and Management"),
                    c("5 - Newborn Care", "0 - Hospital Boarder", 
                      "9 - Organ Procurement - Posthumous")
                    )
for (lump in lst_of_lumps) 
        df$Episode_of_Care_Type[df$Episode_of_Care_Type %in% lump] = 
                paste(lump, collapse="\n")

lst_of_lumps = list(c("11-Transfer to Palliative Care Unit / Hospice", 
                      "3-Transfer to Residential Aged Care Facility"),
                    c("4-Transfer to Public Psychiatric Hospital", 
                      "8-Transfer to Other Accommodation")
                    )
for (lump in lst_of_lumps) 
        df$Mode_of_Separation[df$Mode_of_Separation %in% lump] = 
                paste(lump, collapse="\n")


lst_of_lumps = list(c("3", "9"))
for (lump in lst_of_lumps) 
        df$Medicare_Eligibilty_Status[df$Medicare_Eligibilty_Status %in% lump] = 
                paste(lump, collapse=" | ")
