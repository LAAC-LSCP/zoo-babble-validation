import numpy as np
from collections import defaultdict
import json

# ----------------------------------------------------------------------------------------

#This script creates a dictionary file in json format with mapping from 500ms chunks to Lab annotation segments


result_final="/Users/chiarasemenzin/Desktop/LSCP/SLT/result_final_lisa.csv"  #file with segment info and lab classifications
result_zoon="/Users/chiarasemenzin/Desktop/LSCP/SLT/merged_metadata.csv"  #metadata for zooniverse clips


# Segment to timestamp
def seg_to_ts(result_final):
    seg2ts={}
    with open(result_final) as final:
        for e,line in enumerate(final):
            line=line.split(",")
            if e > 0:
                seg2ts[line[0]]=(float(line[4]),float(line[5]),line[1])
    return seg2ts

# Timestamp to segment
def chunk_to_ts(result_zoon):
    chunk2ts={}
    with open(result_zoon) as zoon:
        for e,line in enumerate(zoon):
            line=line.split(",")
            if e > 0:
                #chunk2ts[line[0]]=[float(i) for i in line[4].split("_")]
                chunk2ts[line[1]]=[float(line[4]),float(line[5])] #get timestamps
                chunk2ts[line[1]].append(line[2]) #get name of chunk
    return chunk2ts

# Calculate average duration of segment
def avg_duration(result_final):
    seg_ts=[]
    with open(result_final) as final:
        for e,line in enumerate(final):
            line=line.split(",")
            if e > 0:
                seg_ts.append(float(line[5])-float(line[4]))
    avg_dur=sum(seg_ts)/len(seg_ts)
    return avg_duration

def check(segments,chunks):
    """" Check which chunks belong to which segment, by file"""

    segments_final = defaultdict(list)

    for name,chunk in chunks.items(): 
        diffs_onset=[]
        diffs_offeset=[]
        candidate_seg=dict([i for i in segments.items() if i[1][2]==chunk[2]])
        for k,seg in candidate_seg.items():
            if seg[2] == chunk[2]:
                print("Looking at ",k,seg[2])
                diffs_onset.append([abs(chunk[0]-seg[0]),k])
                diffs_offeset.append([abs(chunk[1]-seg[1]),k])
        min_on=min([i[0] for i in diffs_onset])
        don=np.array(diffs_onset)
        try:
            idx=int(np.where(don ==str(min_on))[0])
            segment=don[idx,1]
            segments_final[segment].append(name)
        except:
            print("Ambiguous segment. Check manually.") #btw this has never happened but jic
            continue
    print(len(segments_final.items()))
    return segments_final


# ----------------------------------------------------------------------------------------

if __name__ == "__main__":
    s=seg_to_ts(result_final)
    c=chunk_to_ts(result_zoon)
    seg_=check(s,c)
    json = json.dumps(seg_)
    print("Writing file...")
    f = open("dict_4.json","w")
    f.write(json)
    f.close()
    print("Done.")


