library(rjson)
#file that has "subject" information -- in Zooniverse terms, that is info about the file that was classified
zoosj <- read.csv("../data_analyses/output/metadata_all_PU.csv",header=T,sep =",")

#file that has the classifications (ie cit sci answers)
classifs <- read.csv("../data_analyses/files_from_zooniverse/zooniverse_data_all_final.csv",header=T,sep =",")

# <-- solution!! get json data which has classif info & match up using subject_id


#children's info
demo_data <- read.csv("../data_analyses/files_from_elsewhere/demo-data.tsv",header=T,sep ="\t")

#dictionary that relates chunk to segment created by Chiara
dict <- fromJSON(file="../data_analyses/files_from_elsewhere/dict_4.json") 
dict.simple=unlist(dict)

#laboratory annotations
read.csv("../data_analyses/files_from_elsewhere/result_final_lisa.csv")->lab_jud


## Cleaning stuff up ##
# Remove weird answers, which do not belong here
classifs$Answer<-factor(classifs$Answer,levels=c("Canonical","Non-Canonical","Crying","Laughing","Junk"))
summary(classifs$Answer)
classifs=classifs[!is.na(classifs$Answer),]
classifs$AudioData=as.factor(classifs$AudioData)
head(classifs)

# Remove additional votes when there are more than 5, 
# and remove clips with fewer than 5, which likely do not belong to this project
table(classifs$AudioData)->sumvotes
toomany=rownames(sumvotes)[sumvotes>5]
length(toomany)
justright=rownames(sumvotes)[sumvotes==5]
length(justright)
toofew=rownames(sumvotes)[sumvotes<5]
length(toofew)

classifs$nclasschunk=NA
clean=classifs[classifs$AudioData %in% justright,] #start by adding the normal ones
for(thischunk in toomany){
  classifs$nclasschunk[classifs$AudioData==thischunk]<-1:sum(classifs$AudioData==thischunk)
  clean=rbind(clean,classifs[classifs$AudioData==thischunk & classifs$nclasschunk<=5 & !is.na(classifs$nclasschunk),])
}

#check that the procedure worked
clean$AudioData=as.factor(as.character(clean$AudioData))
table(clean$AudioData)->sumvotes
sum(sumvotes>5)
sum(sumvotes==5)
sum(sumvotes<5)

write.csv(clean,"../data_analyses/output/clean_classifications.csv")
read.csv("../data_analyses/output/clean_classifications.csv")->clean
classifs<-clean

## Generate views on the data ##
#combine subject info & classifications
zoosj$AudioData=paste0(zoosj$AudioData,".mp3")
merge(zoosj,classifs,by="AudioData")->chunks

# > length(levels(factor(zoosj$AudioData)))
# [1] 19691
# > length(levels(factor(chunks$AudioData)))
# [1] 17714
# --> we are missing 2k chunks

#use child ID in the chunkID, for ease of processing later
chunks$chunkID=paste(chunks$ChildID,chunks$onset,chunks$AudioData)


# next version collapses across chunks to get the nb of different classifications
table(chunks$chunkID,chunks$Answer)->mytab
sumvotes<- t(t(apply(mytab, 1, sum))) #get the total number of votes
nvotes<- t(t(apply(mytab, 1, max))) #get the number of votes for the most common cat 
mytab_mj <- mytab >= 3  #set as True the answer types that have more than 3 votes
mymj <- t(t(apply(mytab_mj, 1, function(u) paste( names(which(u)), collapse=", " )))) #get the answer that has majority vote
maj_jud=data.frame(cbind(row.names(mytab),unlist(mymj),nvotes,sumvotes)) #combine all info
colnames(maj_jud)<-c("chunkID","Answer","nvotes","sumvotes")

#recover childID
maj_jud$ChildID = gsub(" .*","",maj_jud$chunkID)

#recover AudioData (name of the classified chunk)
maj_jud$AudioData = gsub(".* ","",maj_jud$chunkID)
maj_jud$AudioData = gsub(".mp3","",maj_jud$AudioData)

#check
head(maj_jud)

# next I need to match up the segments with the chunks
maj_jud$segmentId_DB=NA
sum(dict.simple %in% maj_jud$AudioData) # 17714 found
sum(!(dict.simple %in% maj_jud$AudioData)) # 16014 not found

#<-- dict 11980 versus lab_jud has 11982 segmens
# dict has 33728 chunks


#limit to chunks for which we have data, to go faster
for(thischunk in dict.simple[dict.simple %in% maj_jud$AudioData]) maj_jud$segmentId_DB[maj_jud$AudioData==thischunk]<-names(dict.simple[dict.simple==thischunk])
maj_jud$segmentId_DB_old<-maj_jud$segmentId_DB
maj_jud$segmentId_DB=gsub(".$","",maj_jud$segmentId_DB)

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

#write everything out
merge(demo_data,chunks,by="ChildID")->chunks
write.csv(chunks,"../data_analyses/output/chunks_individual_judgments.csv")

merge(demo_data,maj_jud,by="ChildID")->maj_jud2
write.csv(maj_jud2,"../data_analyses/output/chunks_maj_judgments.csv")

write.csv(all_jud,"../data_analyses/output/zoo_lab_maj_judgments.csv")
