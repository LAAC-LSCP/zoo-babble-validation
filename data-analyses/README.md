From Zooniverse raw classifications to chunk- and segment-level analysis

--------------------------------------------------------------

Step 0.  activate a python3 virtualenv: the one you created for the first part of the zooniverse pipeline (data creation & upload) should do.

Step 1. Convert raw zooniverse classifications into right format

$ jupyter notebook Convert_Zooniverse.ipynb
 

--------------------------------------------------------------
Step 2. Metadata merging

you'll need:
    - [ ] All classifications from Zooniverse : zooniverse_data_all_final.csv
    - [ ] Metadata files:
    metadata_all_PU.csv

Open merge_datasets_zoon.py and change paths to metadata and to zooniverse classifs.
Optionally change path to output file created.
Run:

$ python merge_datasets_zoon.py 

--------------------------------------------------------------

Step 3. Segment-chunk conversion

1. Chunk to segment (no need to re-run, output is in /metadata/dict_4.json)

requirements:
    - [ ] result_final=result_final_lisa.csv  #file from PU with segments metadata and lab classifications
    - [ ] result_zoon="/Final_JSLHR/metadata/metadata_all_PU.csv"  #metadata for zooniverse clips

Creates the dict_4.json file with the mapping between segments and chunks which is used in the next step. 


2. Write_seg_data.py

Use the dictionary mapping to determine chunk-level majority agreement and segment-level classification. Then write to a final file which will be used for the analysis.
Change output filename on line 87: 

> total.to_csv("classifications_PU_zoon_final_19oct.csv")

you'll need:
    - [ ] Dictionary segment-chunk mapping (dict_4.json)
    - [ ] Classifications + metadata (from Step 2)


--------------------------------------------------------------

Step 4. Run segment level analysis

	-[ ] SLT_again.Rmd

--------------------------------------------------------------

Step 5. Chunk level analysis

you'll need:
	[ ] chunk_majority_agreement_1751.csv
	[ ] zoon_chunk_level.Rmd
	[ ] ratios_lb_z.csv (created in SLT_again.Rmd)

