# cleaning up files

$ wc -l data_analyses/files_from_elsewhere/*
  19692 data_analyses/files_from_elsewhere/Metadata_batch1b_20200809.csv
14040 data_analyses/files_from_elsewhere/Metadata_batch22020_lisa.csv
20 data_analyses/files_from_elsewhere/demo-data.tsv
0 data_analyses/files_from_elsewhere/dict_4.json
10 data_analyses/files_from_elsewhere/filename_links.csv
33731 data_analyses/files_from_elsewhere/metadata_all_PU.csv
11982 data_analyses/files_from_elsewhere/result_final_lisa.csv

Metadata_batch1b_20200809.csv and Metadata_batch22020_lisa.csv start the same way, so we remove duplicates & merge

## TO KEEP
10 data_analyses/files_from_elsewhere/filename_links.csv contains the mapping between children and recording name
20 data_analyses/files_from_elsewhere/demo-data.tsv contains children's demographic info
result_final_lisa.csv contains lab annotation
 33731 data_analyses/files_from_elsewhere/metadata_all_PU.csv contains all metadata for PU

## TO REMOVE
write_seg_data.pymerge_datasets_zoon.pyConvert_Zooniverse.ipynbchunk_to_segment.py

all of the above are no longer needed, since code/recover_zooniverse_metadata.py can generate a csv with combined metadata+subject info, and the code 202010_jslhr/generate_jslhr_data.R can generate all the intermediate files that could be needed.

dict_4.json was created by a different analysis pipeline --> it can be removed, no longer useful, contains no info

   19692 data_analyses/files_from_elsewhere/Metadata_batch1b_20200809.csv
 14040 data_analyses/files_from_elsewhere/Metadata_batch22020_lisa.csv
are mutually redundant

-- code used to determine this, based on number of lines...
(mypython) (base) Mac-mini:zoo-babble-validation acristia$ cd data_analyses/files_from_elsewhere/
  (mypython) (base) Mac-mini:files_from_elsewhere acristia$ cat Metadata_batch1b_20200809.csv Metadata_batch22020_lisa.csv  metadata_all_PU.csv > combined.csv
(mypython) (base) Mac-mini:files_from_elsewhere acristia$ sort combined.csv | uniq | combined_no_duplicates.csv
-bash: combined_no_duplicates.csv: command not found
(mypython) (base) Mac-mini:files_from_elsewhere acristia$ sort combined.csv | uniq > combined_no_duplicates.csv
(mypython) (base) Mac-mini:files_from_elsewhere acristia$ wc -l
^C
(mypython) (base) Mac-mini:files_from_elsewhere acristia$ wc -l *
  19692 Metadata_batch1b_20200809.csv
14040 Metadata_batch22020_lisa.csv
67463 combined.csv
33731 combined_no_duplicates.csv
20 demo-data.tsv
0 dict_4.json
10 filename_links.csv
33731 metadata_all_PU.csv
11982 result_final_lisa.csv
180669 total