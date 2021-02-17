Describing vocalizations in young children: A big data approach through citizen science annotation

--------------------------------------------------------------

This repo contains the code needed to reproduce a conference paper (202007_SLT) and a journal paper (202010_jslhr). Given that the latter is a later-produced expansion of data and analyses, we only provide information for reproducing the latter.

To reproduce the manuscript, you can simply knit 202010_jslhr/paper.Rmd.

To rerun the whole pipeline:

1. Put the following two files inside files_from_zooniverse/

- maturity-of-baby-sounds-subjects.csv
- zooniverse_data_all_final.csv

These are very large, so they are not synced in the repo.

2. Run data_analyses/code/generate_jslhr_data.R -- this will generate the following key files, which are used in paper.Rmd:

- key_info.csv
- zoo_lab_maj_judgments.csv- chunks_maj_judgments.csv


3. knit 202010_jslhr/paper.Rmd