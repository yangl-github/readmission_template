summ_stats_con_vars = function(dat) {
        function(varname) {
                x = summary(dat[varname])
                tbl = data.frame(x)
                tbl$Var1 = NULL
                tbl$Var2 = gsub("\\s+", "", tbl$Var2)
                tbl$Freq = gsub("[Min|1st|Med|Mea|3rd|Max|NA].*:", "", tbl$Freq)
                lvls = c("Min", "1st Q", "Median", "Mean", "3rd Q", "Max")
                if (nrow(tbl) == 14) lvls = c(lvls, "NA")
                tbl$Summ_Stats = factor(lvls, lvls)
                tbl %>% spread(key=Var2, value = Freq)
        }
}

mk_tbl_cat_var = function(dat) {
        function(varname) {
                tbl = data.frame(table(dat[[varname]]))
                row.names(tbl) = tbl$Var1
                tbl$Var1 = NULL
                NAs = sum(is.na(dat[[varname]]))
                if (NAs == 0) return(tbl)
                tbl = rbind(tbl, NAs = NAs)
                names(tbl) = "n"
                tbl
        }
}

ypct_in_cat_x = function(df, yvar) {
        # Returns a function that takes a categorical xvar name and outputs 
        #       a table of percents of each y level in each level of xvar.
        #
        # df  : data frame
        # yvar: string, name of the response variable
        
        function(xvar) {
                # xvar: string, name of a character/factor xvar
                
                # xvar = "LastEpisode"
                tab = table(df[[xvar]], df[[yvar]])
                # pt = sprintf("%0.1f%%", prop.table(tab, margin=1) * 100)
                # dim(pt) = dim(tab)
                # dimnames(pt) = dimnames(tab)
                pt = prop.table(tab, margin=1) * 100
                tbl = cbind(row.names(tab), apply(tab, 1, sum), 
                            data.frame(pt[,1], pt[,2]))
                names(tbl) = c(xvar, "Count", "Readmission-NO", "Readmission-YES")
                tbl %>% arrange(-`Readmission-YES`) %>% 
                        mutate(`Readmission-YES` = 
                                       sprintf("%0.1f%%", `Readmission-YES`),
                               `Readmission-NO` = 
                                       sprintf("%0.1f%%", `Readmission-NO`))
        }
}
