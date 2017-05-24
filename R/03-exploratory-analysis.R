#' ---
#' title: "Distribution of y Against Each x"
#' author: "Cabaceo LLC"
#' date: "`r Sys.Date()`"
#' output: pdf_document
#' ---

#+ include=FALSE
knitr::opts_chunk$set(comment = "", tidy = F, echo = F, warning = F, 
                      message = F, fig.width = 3.5, fig.height = 4)

#+ results = "asis"

# continuous xvars
plt = mk_boxplot(df)
plt(yvar, "Age", ylab = "Age", xlab = yvar)
p = plt(yvar, "LOS", ylab = "LOS", xlab = yvar)
scale_axis(p, scale = "log10")


# categorical xvars
f = ypct_in_cat_x(df, yvar)
invisible(lapply(c("Age", xvars_cat), function(xvar) 
        print(kable(f(xvar), row.names = F))))


# distribution of LOS
x = summary(df$LOS)
tbl = data.frame(LOS = as.numeric(x))
row.names(tbl) = names(x)
print(kable(tbl, row.names = T))
