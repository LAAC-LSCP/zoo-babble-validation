import pandas as pd 
import os 
import sys
import json
import argparse

parser = argparse.ArgumentParser(description = '')
parser.add_argument('source', help = 'path to the source metadata to convert')
parser.add_argument('destination', help = 'destination path')
parser.add_argument('--subjects', help = 'path to the Zooniverse .csv subjects export', default = 'data_analyses/files_from_zooniverse/maturity-of-baby-sounds-subjects.csv')
parser.add_argument('--links', help = 'path to the dataframe linking ChildID to FileName', default = 'data_analyses/files_from_elsewhere/filename_links.csv')

args = parser.parse_args()

subjects = pd.read_csv(args.subjects)
links = pd.read_csv(args.links)
links.rename(columns = {'FileName': 'recording'}, inplace = True)

def get_name(s):
    try:
        return os.path.splitext(json.loads(s)['Name'])[0]
    except:
        return 'NA'

subjects['AudioData'] = subjects['metadata'].apply(get_name).astype(str)

df = pd.read_csv(args.source, dtype = {'AudioData': str})
df = df.merge(subjects, left_on = 'AudioData', right_on = 'AudioData')
df = df.merge(links, left_on = 'ChildID', right_on = 'ChildID')

df['onset'] = (df['onset']*1000).astype(int)
df['offset'] = (df['offset']*1000).astype(int)

df['onset'] = df['onset'] + 500 * df['chunk_pos']
df['offset'] = df['onset'] + 500

df['speaker_type'] = 'CHI'
df['wav'] = 'NA'
df['mp3'] = 'NA'
df['date_extracted'] = 'NA'
df['uploaded'] = True

df.rename(columns = {'subject_id': 'zooniverse_id'}, inplace = True)

df.to_csv(args.destination, index = False)