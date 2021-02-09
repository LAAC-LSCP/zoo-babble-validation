## PHASE 1 -- RESTRICT ZOONIVERSE DATA TO PU DATA

library(rjson)
getname2=function(x) fromJSON(x)[[1]]

#original chunk metadata
origmetadata <- read.csv("../data_analyses/files_from_elsewhere/metadata_all_PU.csv",colClasses="factor",header=T,sep =",")
dim(origmetadata)
origmetadata$filename=paste0(origmetadata$AudioData,".mp3")
length(levels(factor(origmetadata$filename)))
#33730

# #file that has "subject" information -- in Zooniverse terms, that is info about the file that was classified
zoosj <- read.csv("../data_analyses/files_from_zooniverse/maturity-of-baby-sounds-subjects.csv",header=T,sep =",")
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

write.csv(zoosj_PU,"../data_analyses/output/zoo_subj_info_pu.csv")

read.csv("../data_analyses/output/zoo_subj_info_pu.csv",colClasses="factor",header=T,sep =",")->zoosj

#file that has the classifications (ie cit sci answers)
classifs <- read.csv("../data_analyses/files_from_zooniverse/maturity-of-baby-sounds-classifications.csv",header=T,sep =",")
classifs$subject_id=fromJSON(as.character(classifs[,"subject_data"]))[[1]]$retired$subject_id
length(levels(factor(classifs$subject_id)))
#79162
classifs -> full_classifs
classifs=subset(classifs, classifs$subject_id %in% levels(factor(zoosj$subject_id)))
length(levels(factor(classifs$subject_id)))
#33730 chunks

write.csv(classifs,"../data_analyses/output/zoo_anno_info_pu.csv")

read.csv("../data_analyses/output/zoo_anno_info_pu.csv",colClasses="factor",header=T,sep =",")->classifs

## PHASE 2 -- CLEAN CLASSIFICATIONS

library(rjson)
getval=function(x) fromJSON(x)[[1]]$value
getname=function(x) fromJSON(x)[[1]]$Name


## Cleaning stuff up ##
classifs$Answer=unlist(lapply(as.character(classifs[,"annotations"]), getval))
table(classifs$Answer)

classifs$filename=unlist(lapply(as.character(classifs[,"subject_data"]), getname))
length(levels(factor(classifs$filename)))

# Remove additional votes when there are more than 5, 
# and remove clips with fewer than 5
table(classifs$filename)->sumvotes
toomany=rownames(sumvotes)[sumvotes>5]
length(toomany)
justright=rownames(sumvotes)[sumvotes==5]
length(justright)
toofew=rownames(sumvotes)[sumvotes<5]
length(toofew)
#1 chunk didn't receive 5 votes

classifs$nclasschunk=NA
clean=classifs[classifs$filename %in% justright,] #start by adding the normal ones
for(thischunk in toomany){
  classifs$nclasschunk[classifs$filename==thischunk]<-1:sum(classifs$filename==thischunk)
  clean=rbind(clean,classifs[classifs$filename==thischunk & classifs$nclasschunk<=5 & !is.na(classifs$nclasschunk),])
}

#check that the procedure worked
clean$filename=as.factor(as.character(clean$filename))
table(clean$filename)->sumvotes
sum(sumvotes>5)
sum(sumvotes==5) #33729 chunks
sum(sumvotes<5)

merge(zoosj,clean,by="filename")->chunks

write.csv(chunks,"../data_analyses/output/clean_classifications.csv")

## PHASE 3 -- Generate views on the data: majority judgment on the chunk

#file that contains subject info & annotation info from PU, 
#filtered down to have 5 classifications per subject ID (= chunk)
read.csv("../data_analyses/output/clean_classifications.csv")->chunks

#concatenate childID, filename, onset, chunk_pos in case we need them later
chunks$chunk_info=paste(chunks$ChildID,chunks$filename,chunks$onset,chunks$chunk_pos)

# next version collapses across chunks to get the nb of different classifications
table(chunks$chunk_info,chunks$Answer)->mytab
sumvotes<- t(t(apply(mytab, 1, sum))) #get the total number of votes
nvotes<- t(t(apply(mytab, 1, max))) #get the number of votes for the most common cat 
mytab_mj <- mytab >= 3  #set as True the answer types that have more than 3 votes
mymj <- t(t(apply(mytab_mj, 1, function(u) paste( names(which(u)), collapse=", " )))) #get the answer that has majority vote
maj_jud=data.frame(cbind(row.names(mytab),unlist(mymj),nvotes,sumvotes)) #combine all info
colnames(maj_jud)<-c("chunk_info","Answer","nvotes","sumvotes")

#recover childID
maj_jud$ChildID = gsub(" .*","",maj_jud$chunk_info)

#recover filename (name of the classified chunk)
maj_jud$filename = gsub(".* ","",gsub(".mp3.*",".mp3",maj_jud$chunk_info))


#check
head(maj_jud)

write.csv(maj_jud,"../data_analyses/output/chunks_maj_judgments.csv")


## PHASE 4 -- Generate views on the data: majority judgment on the segment
library(rjson)


#dictionary that relates chunk to segment created by Chiara
dict <- fromJSON(file="../data_analyses/files_from_elsewhere/dict_4.json") 
dict.simple=unlist(dict)
length(dict.simple) 
dict=data.frame(cbind(dict.simple,gsub(".$","",as.character(names(dict.simple)))))
colnames(dict)<-c("chunk","segmentId_DB")
length(levels(factor(dict$chunk)))
#33728 chunks
length(levels(factor(dict$segmentId_DB)))
#12170 segments
#NOTE!!! THERE ARE TWO CHUNKS MISSING FROM THIS DICTIONARY!!!

#laboratory annotations
read.csv("../data_analyses/files_from_elsewhere/result_final_lisa.csv")->lab_jud
dim(lab_jud)
#11982 segments

sum(lab_jud$segmentId_DB %in% levels(factor(dict$segmentId_DB))) #11980 in common
sum(!(lab_jud$segmentId_DB %in% levels(factor(dict$segmentId_DB)))) #2 fund in lab but not dict
sum(!(levels(factor(dict$segmentId_DB)) %in% lab_jud$segmentId_DB )) #190 found in dict but not in lab

#assuming that we should follow lab data, I'll kick out any segment not in there

#chunk info
read.csv("../data_analyses/output/chunks_maj_judgments.csv",colClasses="factor")->maj_jud
maj_jud$AudioData=gsub(".mp3","",maj_jud$filename)


# next I need to match up the segments with the chunks
sum(dict.simple %in% maj_jud$AudioData) # 33727 found
sum(!(dict.simple %in% maj_jud$AudioData)) # 1 not found

rownames(dict)<-dict$chunk
maj_jud$segmentId_DB <- dict[maj_jud$AudioData,"segmentId_DB"]
length(levels(factor(maj_jud$segmentId_DB))) #12170

#generate majority at the segment level using our rule:
# canonical > non-canonical > crying > laughing > junk
table(maj_jud$segmentId_DB,maj_jud$Answer)->mytab
mytype<-ifelse(mytab[,"Canonical"]>0,"Canonical",
               ifelse(mytab[,"Non-Canonical"]>0,"Non-Canonical",
                      ifelse(mytab[,"Crying"]>0,"Crying",
                             ifelse(mytab[,"Laughing"]>0,"Laughing",
                                    ifelse(mytab[,"Junk"]>0,"Junk",""
                      )))))

zoo_jud=cbind(row.names(mytab),mytype)
colnames(zoo_jud)<-c("segmentId_DB","Answer")

merge(zoo_jud,lab_jud,by="segmentId_DB")->all_jud
#11980 segments

write.csv(all_jud,"../data_analyses/output/zoo_lab_maj_judgments.csv")

