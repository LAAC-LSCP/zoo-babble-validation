import pandas as pd
import numpy as np
from collections import defaultdict, Counter
import json

# ----------------------------------------------------------------------------------------
# Load data

result_zoon="/Users/chiarasemenzin/Desktop/LSCP/SLT/classifications_17sept.csv" #classifs from zooniverse merged with md
zoon=pd.read_csv(result_zoon)
lisa=pd.read_csv("/Users/chiarasemenzin/Desktop/LSCP/SLT/result_final_lisa.csv") #file with metadata and PU classifications
stats_log="stats_log.txt" #give a name to the log 

with open("/Users/chiarasemenzin/Desktop/LSCP/SLT/dict_3.json", "r") as read_file: # Put here path to json file 
    print("Converting JSON encoded data into Python dictionary")
    d = json.load(read_file)


# ----------------------------------------------------------------------------------------


def agreement_by_chunk(d,classifs):
    """Determine majority agreement within chunks"""
    answers = defaultdict(list)
    no_maj_count=0
    no_3_labels=0
    valid_count=0
    total_labels=0
    for k,v in d.items():
        for chunk in v:
            c=Counter(list(classifs.loc[classifs["AudioData"] == int(chunk)]["Answer"]))
            total_labels+=len(c)
            if len(c)!= 0:
                value, count = c.most_common()[0]
                print(sum([i for i in c.values()]))
                if count >= 3 and sum([i for i in c.values()])>=3: #at least 3 classifs agree
                    answers[k].append(value)
                    valid_count+=1
                    #print("Okay")
                elif count < 3 and sum([i for i in c.values()])>=3:
                    #print("No majority agreement")
                    no_maj_count+=1
                else:
                    #print("Not enough data")
                    no_3_labels+=1
    log = open(stats_log, "w")
    log.write(" Valid clips: {}\n No majority agreement: {}\n Less than 3 labels: {}, total labels: {}".format(valid_count,no_maj_count,no_3_labels,total_labels))
    log.close()
    return answers


def agreement_by_segment(answers):
    """Determine classification within segment """
#    TODO
    seg_dict=[[],[]]
    for k,v in answers.items():
        if set(v) != {"Junk"}: # Check Junk is not the only answer
            v=[value for value in v if value != "Junk"] #remove junk
            if len(set(v)) == 1: # 100% agreement 
                classif = v[0]
            elif len(v)%2 == 0 and len(set(v)) == 2:  # 50/50 
                if "Canonical" in v and "Non-Canonical" in v: # if Can & NonCan = Can
                    classif="Canonical"
                else:
                    classif = "Mixed_" + list(set(v))[0] + "_" + list(set(v))[1] # Otherwise mixed
            elif "Canonical" in v and "Non-Canonical" in v: #not sure about this
                classif="Canonical"
            else:
                classif= "Mixed_"+"_".join([i for i in set(v)])
                print(classif)
        else:
            classif="Junk" # Junk only
        seg_dict[0].append(k)
        seg_dict[1].append(classif)
    return seg_dict


# ----------------------------------------------------------------------------------------

if __name__ == "__main__":
    answers = agreement_by_chunk(d, zoon)
    d_final = agreement_by_segment(answers)
    zooniverse=pd.DataFrame(d_final).transpose()
    zooniverse.columns=["segmentId_DB","Zoon_classif"]
    total=pd.merge(lisa,zooniverse,on="segmentId_DB")
    total.to_csv("classifications_PU_zoon_final17.csv")




