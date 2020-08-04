import pandas as pd
import numpy as np
from collections import defaultdict, Counter
import json

# ----------------------------------------------------------------------------------------
# Load data

result_zoon="/Users/chiarasemenzin/Desktop/SLT/first_class_lisa.csv"
zoon=pd.read_csv(result_zoon)
lisa=pd.read_csv("result_final_lisa.csv") #file with metadata and PU classifications


with open("/Users/chiarasemenzin/Desktop/SLT/dict.json", "r") as read_file:
    print("Converting JSON encoded data into Python dictionary")
    d = json.load(read_file)


# ----------------------------------------------------------------------------------------

def agreement_by_chunk(d,classifs):
    """Determine majority agreement within chunks"""
    answers = defaultdict(list)
    for k,v in d.items():
        for chunk in v:
            c=Counter(list(classifs.loc[classifs["AudioData"] == chunk+".mp3" ]["Answer"]))
            if len(c)!= 0:
                value, count = c.most_common()[0]
                if count >= 3 and sum([i for i in c.values()])>=3: #at least 3 classifs agree
                    answers[k].append(value)
                    print("Okay")
                else:
                    print("No majority agreement")
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
    total.to_csv("final_classifications_PU_zoon.csv")




