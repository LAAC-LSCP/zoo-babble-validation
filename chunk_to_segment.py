import numpy as np
from collections import defaultdict
import json


result_final="/Users/chiarasemenzin/Desktop/SLT/result_final_lisa.csv"
result_zoon="/Users/chiarasemenzin/Desktop/SLT/Metadata_batch2_lisa.csv"

# ----------------------------------------------------------------------------------------

def seg_to_ts(result_final):
    seg2ts={}
    with open(result_final) as final:
        for e,line in enumerate(final):
            line=line.split(",")
            if e > 0:
                seg2ts[line[0]]=(float(line[4]),float(line[5]),line[1])
    return seg2ts


def chunk_to_ts(result_zoon):
    chunk2ts={}
    with open(result_zoon) as zoon:
        for e,line in enumerate(zoon):
            line=line.split("\t")
            if e > 0:
                chunk2ts[line[0]]=[float(i) for i in line[4].split("_")]
                chunk2ts[line[0]].append(line[2])
    return chunk2ts


def check(segments,chunks):
    """" Check which chunks belong to which segment"""

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
            print("Ambigous segment. Check manually.")
            continue
    print(list(segments_final.items())[0:100])
    return segments_final


# ----------------------------------------------------------------------------------------

if __name__ == "__main__":
    s=seg_to_ts(result_final)
    c=chunk_to_ts(result_zoon)
    seg_=check(s,c)
    json = json.dumps(seg_)
    f = open("dict.json","w")
    f.write(json)
    f.close()


