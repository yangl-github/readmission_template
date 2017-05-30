# df = read_rds(file.path(cleaned_path, "df.rds"))
# xvars = read_rds(file.path(cleaned_path, "xvars.rds"))
# xvars_cat = read_rds(file.path(cleaned_path, "xvars_cat.rds"))
# xvars_con = read_rds(file.path(cleaned_path, "xvars_con.rds"))
for (var in xvars_cat) df[[var]] = factor(df[[var]])

# down-sample
# table(df[[yvar]])
set.seed(9283)
df = downSample(x = df[xvars], 
                y = factor(ifelse(df[[yvar]] == 1, "Y", "N"), 
                           levels = c("Y", "N")), yname = yvar)
# table(df[[yvar]])


## BEGIN ML algorithm: C5.0 rule based models ##

# idx_train = 1:5000
# ytrain = y[idx_train]
# Xtrain = df[idx_train, xvars]

ytrain = df[[yvar]]
Xtrain = df[xvars]

# single ruleset
rules = C5.0(Xtrain, ytrain, rules = T)
summary(rules)





# set up control parameters for caret::train
ctrl = trainControl(method = "cv", # when using "cv", repeats will be ignored
                    number = 5,
                    summaryFunction = twoClassSummary,
                    classProbs = T, savePredictions = T,
                    allowParallel = T
                    )

grid = expand.grid(trials = 1:5, # c(1:9, (1:10)*10),
                   model = c("tree", "rules"), # 
                   winnow = T # remove uninformative features
                   )

set.seed(476)
fit = train(Xtrain, ytrain, method = "C5.0", tuneGrid = grid,
            verbose = FALSE, metric = "ROC", trControl = ctrl)
fit

fit$pred = merge(fit$pred,  fit$bestTune)
CM = confusionMatrix(fit, norm = "none")

roc = roc(response = fit$pred$obs,
          predictor = fit$pred$successful,
          levels = rev(levels(fit$pred$obs)))



## END ML algorithm: C5.0 rule based models ##