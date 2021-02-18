Describing vocalizations in young children: A big data approach through citizen science annotation

--------------------------------------------------------------

This repo contains the code needed to reproduce a conference paper (202007_SLT) and a journal paper (202010_jslhr). Given that the latter is a later-produced expansion of data and analyses, we only provide information for reproducing the latter.

To reproduce the manuscript, you can simply knit 202010_jslhr/paper.Rmd. NOTE! If you are not in the LAAC team, this is probably the only step you can reproduce. If you want to reproduce the other steps, write to alecristia@gmail.com

To rerun the whole pipeline:

1. Put the following two files inside files_from_zooniverse/

- maturity-of-baby-sounds-subjects.csv contains information about all the clips that have been put up on zooniverse
- maturity-of-baby-sounds-classifications.csv contains information about all the classifications that have been done on zooniverse

These are very large, so they are not synced in the repo.

2. Run data_analyses/code/generate_jslhr_data.R. This will just select down the subject and classification data to the filenames in the PU dataset. In addition, this step will generate `key_info.csv`, which is used in paper.Rmd, as well as the following files, which are used in preprocess.R:

- zoo_subj_info_pu.csv contains information about the PU clips that have been put up on zooniverse- zoo_anno_info_pu.csv contains information about the classifications that have been done on zooniverse for the PU clips specifically



3. Run 202010_jslhr/preprocess.R, which has three steps: cleaning errors in the classifications, generating chunk- and segment-level data. NOTE!! that this file generates `data_analyses/output/clean_classifications.csv`, another large file that is not synced but is necessary for this process. It'll generate the two key files which are used in paper.Rmd:

- zoo_lab_maj_judgments.csv- chunks_maj_judgments.csv

4. knit 202010_jslhr/paper.Rmd