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

# show summary stats of the continuous xvars
f = summ_stats_con_vars(df)
print(kable(f(xvars_con), row.names = F))
cat("\n")

# plot y ~ each continuous var
plt = mk_boxplot(df)
p = plt(yvar, xvars_con[1], ylab = xvars_con[1], xlab = yvar)
print(scale_axis(p, scale = "log10"))
p = plt(yvar, xvars_con[2], ylab = xvars_con[2], xlab = yvar)
print(p)


# print distribution of  y ~ each cat var
g = ypct_in_cat_x(df, yvar)
invisible(lapply(xvars_cat, function(xvar) 
        print(kable(g(xvar), row.names = F)))
)



