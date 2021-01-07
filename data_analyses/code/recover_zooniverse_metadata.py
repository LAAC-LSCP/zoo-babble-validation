import pandas as pd 
import os 
import sys
import json

source = sys.argv[1]
destination = sys.argv[2]

subjects = pd.read_csv('data_analyses/maturity-of-baby-sounds-subjects.csv')
links = pd.read_csv('data_analyses/metadata/filename_links.csv')
links.rename(columns = {'FileName': 'recording'}, inplace = True)

def get_name(s):
    try:
        return os.path.splitext(json.loads(s)['Name'])[0]
    except:
        return 'NA'

subjects['AudioData'] = subjects['metadata'].apply(get_name).astype(str)

df = pd.read_csv(source, dtype = {'AudioData': str})
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

df.to_csv(destination, index = False)