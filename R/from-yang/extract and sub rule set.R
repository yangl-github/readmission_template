

## the rules set output by rpart.utils contains all the nodes and nodes values 
## from root to rach leaf, which means
## in one split rule, same vairable may occrus multiples times
## we will only keep the variable values show last time in the rule
## this will be done in the second part: subset rules set

library(RevoScaleR)
library(rpart)
library(rpart.utils) # for output rules set

## Part I:extract rules set

## read in data sets for training model
df2<-Training_inSQL[,c("Medical_Officer_1_Unit",
                       "Episodes_Source_of_Referral_Code","Facility_ID","DRG_Group",
                       "DRG_Complex","AdmWard","Mode_of_Separation_Code",
                       "SRG_Code","LastEpisode","AgeGroup",
                       "Episodes_PDx_Code","PPH_Category","ED_Mode_of_Arrival_Desc","HadPPH","HadMH",
                       "Complications","New_Postcode","Sex","LOS_Group","Days_in_ICU",
                       "Funded_Code","Aboriginality_Description","unplanned_readmit_28_Days")]
str(df2)
df2$Episodes_Source_of_Referral_Code <- as.factor(df2$Episodes_Source_of_Referral_Code)
df2$Funded_Code <- as.factor(df2$Funded_Code)
df2$unplanned_readmit_28_Days<-as.factor(df2$unplanned_readmit_28_Days)
str(df2)
prop.table(table(df2$unplanned_readmit_28_Days))#17%
Training_set<-df2

## build model
library(ROSE)
undersampling_training <- ovun.sample(unplanned_readmit_28_Days ~ ., data = Training_set, method="under",seed = 1)$data
undersampling_training<-droplevels(undersampling_training)
str(undersampling_training)

vars <- paste(colnames(Training_set)[-23],collapse='+')#all column names except the 25th variable
form <- paste('unplanned_readmit_28_Days~',vars)
form


Tree_Mod <- rxDTree(form,undersampling_training)

# extract Rules set
prob<-as.data.frame(Tree_Mod$frame$yval2) #probability and coverage proportion for each classification
f<-Tree_Mod$frame #nodes type and class

f$Node<-rownames(f)
f1 <- f[c("Node","var","n","yval")]#convert rownames as the first column in the data frame
f2<-cbind(f1,prob$nodeprob) # proportion of records fall into this node
f3 <- cbind (f2,prob$V5) # probability of Readmit classification in this node
f4 <- f3[which(f3$var=="<leaf>"),]

##extract rules set table using rpart.utils
Tree_Mod <- rxDTree(form,data= undersampling_training)

rule_table<-rpart.rules.table (as.rpart(Tree_Mod))
rule_table1 <- rule_table[ which(rule_table$Leaf==TRUE), ]#keep only leaf nodes
rule_table2<-rule_table1[c("Rule","Subrule")] #remove column Leaf
subrule_table<-rpart.subrules.table(as.rpart(Tree_Mod))
subrule_table1<- subrule_table[c("Subrule","Variable","Value")] #remove columns Less and Greater

m <- merge(rule_table2,subrule_table1,by.x="Subrule",by.y = "Subrule", all = TRUE)
m<-m[c("Rule","Subrule","Variable","Value")] # re-order
# m1<-m[order(m$Rule),]

##combine two parts to generate full rules table
m2<- merge(m,f4,by.x="Rule",by.y = "Node", all = TRUE)
m2$var <- NULL#keep only rule information we need
names(m2)<-c("Leaf","Subrule","Variable_of_Subrule","Variable_level","Coverage_number","Classification","Coverage_rate","Probability_of_Classification")
m3 <- m2[order(m2$Leaf,m2$Subrule),]
rules_set<-m3

## Part II: Subset Rules set to keep variable values show last time in the split

## Define a function: for a node, subset its rules set
## to keep only the last splits for each attribute
get.rulesub.func <- function(one_node){
  ## split data set by var
  var.ls <- split(one_node,one_node$Variable_of_Subrule,drop = TRUE)
  # head(var.ls[[1]])
  ## for each subset of a var, subset to get its domain values for last split
  subrule.ls <- lapply(var.ls,function(df){
    new_df <- df[df$Subrule_num==max(df$Subrule_num),]
  })
  
  subrule.df <- do.call(rbind,subrule.ls)
  return(subrule.df)
}


## Split Subrule String to only keep number part
rules_set$Subrule_num <- as.numeric(substring(rules_set$Subrule,2))

## get subrule set for the whole rule set
node.ls <- split(rules_set, rules_set$Leaf, drop = TRUE)
sub_rule_set.ls <- lapply(node.ls,get.rulesub.func)
sub_rule_set <- do.call(rbind,sub_rule_set.ls) #33210/#97551

length(unique(rules_set$Leaf))#103
length(unique(sub_rule_set$Leaf))#103/104431

