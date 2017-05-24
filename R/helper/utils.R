ypct_in_cat_x = function(df, yvar) {
        # Returns a function that takes a categorical xvar name and outputs 
        #       a table of percents of each y level in each level of xvar.
        #
        # df  : data frame
        # yvar: string, name of the response variable
        
        function(xvar) {
                # xvar: string, name of a character/factor xvar
                
                tab = table(df[[xvar]], df[[yvar]])
                pt = sprintf("%0.1f%%", prop.table(tab, margin=1) * 100)
                dim(pt) = dim(tab)
                dimnames(pt) = dimnames(tab)
                tbl = cbind(row.names(tab), apply(tab, 1, sum), data.frame(pt))
                names(tbl) = c(xvar, "Count", "Readmission-NO", "Readmission-YES")
                tbl %>% arrange(-Count)
        }
}
