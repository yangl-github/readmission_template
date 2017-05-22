library(RevoTreeView) #for create tree view
library(RevoScaleR) #for model training and validating
library(ROSE) #for re-balance data
library(RODBC) #for load data from SQL Server

# read in data sets from SQL Server
ch <- odbcConnect("DataMining1")
df <- sqlFetch(ch, "Training_deploy")
df1 <- sqlFetch(ch, "Testing_set_Both")

df2<-df[,c("Facility_ID","HadPPH","HadMH","Sex","Age","LOS","SRG_Desc",
           "Aboriginality_Description","unplanned_readmit_28_Days")]
df2$Age<-as.factor(df2$Age)
df2$LOS<-as.factor(df2$LOS)
df2$unplanned_readmit_28_Days<-as.factor(df2$unplanned_readmit_28_Days)
str(df2)

# df3<-df1[,c("Facility_ID","HadPPH","HadMH","Sex","Age","LOS","SRG_Desc",
#             "Aboriginality_Description","unplanned_readmit_28_Days")]
# df3$Age<-as.factor(df3$Age)
# df3$LOS<-as.factor(df3$LOS)
# str(df3)

set.seed(7)
ss <- sample(1:nrow(df2),size = 0.8*nrow(df2))
Training_set <- df2[ss,] #362860
Testing_set <- df2[-ss,] #120954
Training_set<-droplevels(Training_set)
Testing_set<-droplevels(Testing_set)
Training_set$unplanned_readmit_28_Days<-as.factor(Training_set$unplanned_readmit_28_Days)
str(Training_set)
str(Testing_set)

# rebalanced training set
prop.table(table(Training_set$unplanned_readmit_28_Days)) #0.17
undersampling_training <- ovun.sample(unplanned_readmit_28_Days ~ ., 
                                      data = Training_set, method="under",
                                      seed = 2)$data
undersampling_training<-droplevels(undersampling_training)
prop.table(table(undersampling_training$unplanned_readmit_28_Days)) #0.5

# train model
DTreeMOd<-rxDTree(unplanned_readmit_28_Days~Facility_ID+HadPPH+HadMH+Sex
                  +Age+LOS+SRG_Desc+Aboriginality_Description,
                  data = undersampling_training,maxDepth =12,minBucket =10)
DTreeMOd$variable.importance
#DTreeMOd$cptable

# validate model on re-balanced training set
DTreePred1<-rxPredict(DTreeMOd,data =undersampling_training,extraVarsToWrite = "unplanned_readmit_28_Days" )
DTreePred1$isClass<-ifelse(DTreePred1$X1_prob>0.5,1,0)
confusion.matrix1<-table(Actural=DTreePred1$unplanned_readmit_28_Days,Predicted=DTreePred1$isClass)
confusion.matrix1
# 38786 24526
# 14296 49008 #0.7741691

# validate model on testing set
DTreePred2<-rxPredict(DTreeMOd,data =Testing_set,extraVarsToWrite = "unplanned_readmit_28_Days" )
DTreePred2$isClass<-ifelse(DTreePred2$X1_prob>0.5,1,0)
confusion.matrix2<-table(Actural=DTreePred2$unplanned_readmit_28_Days,Predicted=DTreePred2$isClass)
confusion.matrix2
# 59252 43786
# 5495 15535 #0.7387066
#str(DTreePred2)
DTreePred2$unplanned_readmit_28_Days<-as.integer(as.character(DTreePred2$unplanned_readmit_28_Days))
roc <- rxRoc(actualVarName = "unplanned_readmit_28_Days",
             predVarNames = "X1_prob",data = DTreePred2)
plot(roc)

# create tree view
#plot(createTreeView(DTreeMOd))

#length(levels(df2$SRG_Desc)) #44
#length(levels(df2$Facility_ID)) #56
