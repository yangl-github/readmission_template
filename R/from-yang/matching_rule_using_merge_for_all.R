library(RODBC)
library(dplyr)
library(readr)

#read in rule set and patient set
## please repalce data frame Rules_inSQL by data loaded 
    ##from csv file RulesSet
## please replace data frame Patient_inSQL by data loaded 
    ##from csv file NewPatientsRecords

ch <- odbcConnect("DataMining1")
Rules_inSQL <- sqlFetch(ch, "DTreeRuleSet_Complex")
length(unique(Rules$Leaf))#2919
Patient_insSQL <- sqlFetch(ch, "ReadmissionPredictedResults_Complex")
Rules<-Rules_inSQL
Patient<-Patient_insSQL
str(Rules)
Rules$Leaf<-as.factor(Rules$Leaf)
Rules$Variable<-as.character(Rules$Variable)
Rules$Variable_level<-as.character(Rules$Variable_level)
str(Rules)


#define a funtion to find match for one patient for one rule
match_per_rule<-function(one_rule,one_patient){
  #replace p.df2 with one_patient
  m1<-merge(one_rule,one_patient, by="Variable") # keep only rows in one_rule where name matched
  str(m1)
  ori.ls2<-split(m1,m1$Variable,drop=TRUE)
  out.ls2<-lapply(ori.ls2,function(current.var){
    
    match<-current.var[as.character(current.var$Variable_level.x)==as.character(current.var$Variable_level.y),]
    return(match)
  })
  one_rule_match <- do.call(rbind,out.ls2)
  if(nrow(one_rule_match)==length(out.ls2)){
    one_rule$isMatch<-1
    one_rule$count_of_matchedvar<-length(out.ls2)
  }else{
    one_rule$isMatch<-0
    one_rule$count_of_matchedvar<-0
  }
  
  return(one_rule)
  
}

#define a function to find match for one patient 
match_per_patient<-function(ruleset,t_onepatient,onepatient){
#split rule

#t_onepatient is in transpose format
ori.ls1<-split(ruleset,ruleset$Leaf,drop = TRUE)

out.ls1<-lapply(ori.ls1,function(current.rule){
  matched_table<-match_per_rule(current.rule,t_onepatient)
  return(matched_table)
})
one_patient_match <- do.call(rbind,out.ls1)

if(nrow(one_patient_match[one_patient_match$isMatch==1,])>0){
  a<-droplevels(one_patient_match[one_patient_match$isMatch==1,])
  b<-droplevels(a[a$count_of_matchedvar==max(a$count_of_matchedvar),])
  rule<-unique(b$Leaf)
}else{
  rule<-0
}

matched_table1<-cbind(onepatient,rule)
return(matched_table1)
}

#match for all patient
#split patient
Patient$rownumber<-rownames(Patient)
Patient<-Patient[c(41,1:40)]
str(Patient)
Patient$rownumber<-as.factor(Patient$rownumber) #row number from chr to factor
Patient1<-droplevels(Patient[1:10,])
ori.ls<-split(Patient1,Patient1$rownumber,drop = TRUE)

start.time <-Sys.time()
out.ls<-lapply(ori.ls,function(current.patient){
  
  #prepare current.patient
  current.patient1<-as.data.frame(t(current.patient))
  current.patient1$Var<-row.names(current.patient1)
  current.patient1<-current.patient1[c(2,1)]
  names(current.patient1)<-c("Variable","Variable_level")
  #str(current.patient1) #chr,factor
  current.patient1$Variable_level<-as.character(current.patient1$Variable_level)
  #str(current.patient1) #chr,chr
  
  matched_patient_rule<-match_per_patient(Rules,current.patient1,current.patient)
  return(matched_patient_rule)
  
})
matched_patient_rule<-do.call(rbind,out.ls)
matched_patient_rule1<-matched_patient_rule[-1]
finish.time <- Sys.time()
time.used <-finish.time-start.time

