## PHASE 1 -- RESTRICT ZOONIVERSE DATA TO PU DATA

library(rjson)
getname2=function(x) fromJSON(x)[[1]]

#original chunk metadata
origmetadata <- read.csv("../files_from_elsewhere/metadata_all_PU.csv",colClasses="factor",header=T,sep =",")
dim(origmetadata)
origmetadata$filename=paste0(origmetadata$AudioData,".mp3")
length(levels(factor(origmetadata$filename)))
levels(origmetadata$ChildID)
#33730

# #file that has "subject" information -- in Zooniverse terms, that is info about the file that was classified
zoosj <- read.csv("../files_from_zooniverse/maturity-of-baby-sounds-subjects.csv",header=T,sep =",")
zoosj$filename=unlist(lapply(as.character(zoosj[,"metadata"]), getname2))
length(levels(factor(zoosj$filename)))
#154063
sum(levels(factor(zoosj$filename)) %in% levels(factor(origmetadata$filename)))
#33730

merge(origmetadata,zoosj,by="filename")->zoosj_PU
dim(zoosj_PU)
#33881 because some of the names are repeated
mytab=table(zoosj_PU$filename)
length(names(mytab[mytab==2]))
#exploration revealed that one batch of 151 was uploaded twice -- removing the second upload
for(mych in names(mytab[mytab==2])){
  second_upload_id=max(zoosj_PU[zoosj_PU$filename==mych,"subject_id"])
  zoosj_PU=zoosj_PU[zoosj_PU$subject_id!=second_upload_id,]
}
dim(zoosj_PU)
#33730

write.csv(zoosj_PU,"../output/zoo_subj_info_pu.csv") #all 20 kids are in here




read.csv("../output/zoo_subj_info_pu.csv",colClasses="factor",header=T,sep =",")->zoosj

#file that has the classifications (ie cit sci answers)
classifs <- read.csv("../files_from_zooniverse/maturity-of-baby-sounds-classifications.csv",header=T,sep =",")
classifs$subject_id=fromJSON(as.character(classifs[,"subject_data"]))[[1]]$retired$subject_id
length(levels(factor(classifs$subject_id)))
#151991
classifs -> full_classifs
classifs=subset(classifs, classifs$subject_id %in% levels(factor(zoosj$subject_id)))
length(levels(factor(classifs$subject_id)))
#33730 chunks

write.csv(classifs,"../output/zoo_anno_info_pu.csv")


#An impressive total of `r length(levels(factor(judgments$user_id)))` 
#individual Zooniverse users provided `r dim(judgments)[1]` judgments on 
#`r length(levels(factor(judgments$subject_ids)))` 500-ms chunks
keyinfo=c(length(levels(factor(classifs$user_id))),
          dim(classifs)[1],
          length(levels(factor(classifs$subject_ids))))
names(keyinfo)<-c("nusers","njudgments","nchunks")

write.csv(keyinfo,"../output/key_info.csv")




