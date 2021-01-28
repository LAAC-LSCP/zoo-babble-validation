#TODO rather than removing them, take the first 5 judgments

x <- read.csv("../data_analyses/output/metadata_all_PU.csv",header=T,sep =",")
y <- read.csv("../data_analyses/files_from_zooniverse/zooniverse_data_all_final.csv",header=T,sep =",")

# Remove weird answers, which do not belong here
y$Answer<-factor(y$Answer,levels=c("Canonical","Non-Canonical","Crying","Laughing","Junk"))
summary(y$Answer)
y=y[!is.na(y$Answer),]

# Remove additional votes when there are more than 5? I'm not sure it's the case, perhaps these are repeated names?
table(y$AudioData)->sumvotes
sum(sumvotes>5)
#rownames(sumvotes)[sumvotes>5]

x$AudioData=paste0(x$AudioData,".mp3")
merge(x,y,by="AudioData")->chunks

chunks$chunkID=paste(chunks$ChildID,chunks$onset)

#merge with children's info
demo_data <- read.csv("../data_analyses/files_from_elsewhere/demo-data.tsv",header=T,sep ="\t")
merge(demo_data,chunks,by="ChildID")->chunks

write.csv(chunks,"../data_analyses/output/chunks_individual_judgments.csv")

# next version collapses across chunks to get the nb of different classifications
table(chunks$chunkID,chunks$Answer)->mytab
sumvotes<- t(t(apply(mytab, 1, sum))) #get the total number of votes

#TODO rather than removing them, take the first 5 judgments
#some clips have been voted too many times --> remove them from consideration
row.names(mytab)[sumvotes>5]->exclude
chunks[!(chunks$chunkID %in% exclude),]->chunks

#redo the table & the stats
table(chunks$chunkID,chunks$Answer)->mytab
nvotes<- t(t(apply(mytab, 1, max))) #get the number of votes for that 

mytab_mj <- mytab >= 3  #set as True the answer types that have more than 3 votes
mymj <- t(t(apply(mytab_mj, 1, function(u) paste( names(which(u)), collapse=", " )))) #get the answer that has majority vote

maj_jud=data.frame(cbind(row.names(mytab),unlist(mymj),nvotes))
colnames(maj_jud)<-c("chunkID","Answer","nvotes")

maj_jud$ChildID = gsub(" .*","",maj_jud$chunkID)

#add participant information
merge(demo_data,maj_jud,by="ChildID")->maj_jud2

write.csv(maj_jud2,"../data_analyses/output/chunks_maj_judgments.csv")

# next I need to match up the segments with the chunks
x$SegmentOnset=x$onset
for(i in 1:dim(x)[1]) {
  correction=x$chunk_pos[i]
  x$SegmentOnset[i]<-x$SegmentOnset[i-correction]
}
x$chunkID = paste(x$ChildID,x$onset)

merge(x[,c("chunkID","SegmentOnset")],maj_jud,by="chunkID")->maj_jud

maj_jud$segID <- paste(maj_jud$ChildID,maj_jud$SegmentOnset)

#generate majority at the segment level using our rule:
# canonical > non-canonical > crying > laughing > junk

table(maj_jud$segID,maj_jud$Answer)->mytab
mytype<-ifelse(mytab[,"Canonical"]>0,"Canonical",
               ifelse(mytab[,"Non-Canonical"]>0,"Non-Canonical",
                      ifelse(mytab[,"Crying"]>0,"Crying",
                             ifelse(mytab[,"Laughing"]>0,"Laughing",
                                    ifelse(mytab[,"Junk"]>0,"Junk",""
                      )))))

zoo_jud=cbind(row.names(mytab),mytype)
colnames(zoo_jud)<-c("segID","Answer")

read.csv("../data_analyses/files_from_elsewhere/result_final_lisa.csv")->lab_jud
lab_jud$segID <- paste(lab_jud$ChildID,lab_jud$Starttime)

merge(zoo_jud,lab_jud,by="segID")->all_jud
#This fails because the onsets get messed up
