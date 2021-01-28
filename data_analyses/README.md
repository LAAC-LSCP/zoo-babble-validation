From Zooniverse raw classifications to chunk- and segment-level analysis

--------------------------------------------------------------

## Step 0.  Installation

### 1. Install Python 3
Find here instructions on how to install Python for 
[Linux](https://docs.python-guide.org/starting/install3/linux/) ,
[MacOS](https://docs.python-guide.org/starting/install3/osx/) and 
[Windows](https://docs.python-guide.org/starting/install3/win/).

### 2. Create the virtual environment using the venv module included with Python3.
For example to create one in the local directory called ?mypython?, type the following:

Mac OS / Linux
```
python3 -m venv mypython
```
Windows
```
py -m venv mypython
```

### 3. Activate the virtual environment
You can activate the python environment by running the following command:

Mac OS / Linux
```
source mypython/bin/activate
```
Windows
```
mypthon\Scripts\activate
```
Then you can confirm you're in the virtual environment by checking the location of your Python interpreter, it should point to the env directory.

On macOS and Linux:
```
which python
.../env/bin/python
```
On Windows:
```
where python
.../env/bin/python.exe
```
As long as your virtual environment is activated pip will install packages into that specific environment and you?ll be able to import and use packages in your Python application.

If you want to switch projects or otherwise leave your virtual environment, simply run:
```
deactivate
```

### 4. Add needed packages

Python packages required:

* jupyter
* pandas


all packages can be installed with [pip](https://pip.pypa.io/en/stable/installing/):
```
pip install pydub
```


In the future, when you want to re-enter the virtual environment just follow the same instructions above about activating a virtual environment. There's no need to re-create the virtual environment nor re-install the packages.

It is assumed that you are working at the top level of the github repo. All scripts are in `data_analyses/code/`. In addition, we assume you put files from zooniverse (subjects' description, classifications) inside `data_analyses/files_from_zooniverse`, and that you put other (including human-generated) files inside `data_analyses/files_from_elsewhere`. 

## Step 1. If needed, activate python 3 env

ONLY DO THIS IF NEEDED

Mac OS / Linux
```
source mypython/bin/activate
```
Windows
```
mypthon\Scripts\activate
```


## Step 2. Combine chunk metadata with chunk within-zooniverse subject descriptions, with child/recording information

This step takes as input:

1) chunk metadata (in this case, files_from_elsewhere/metadata_all_PU.csv)
2) chunk within-zooniverse subject descriptions (not passed as a parameter here, in this case files_from_zooniverse/maturity-of-baby-sounds-subjects.csv)
3) a file linking ChildID's to filenames (not passed as a parameter here, files_from_elsewhere/filename_links.csv)

```
$ python data_analyses/code/recover_zooniverse_metadata.py data_analyses/files_from_elsewhere/metadata_all_PU.csv data_analyses/output/metadata_all_PU.csv
```

This step produces a file that contains, for each chunk, information from metadata_all_PU.csv as well as the subject description. We will call this our new chunk metadata file.

## Step 3. Combine chunk metadata with chunk-level classifications

This step combines chunk metadata with chunk-level classifications, so that now we will have each and every one of the citizen scientists' responses with information about the chunk (including child ID, etc)

## Step 4. Combine chunk-level information together so as to generate segment-level information.


$ jupyter notebook Convert_Zooniverse.ipynb
 
This will launch a window in which you can view the re-generated results. It will also create XXX. Do Ctrl+C in your terminal to close this process and move on to the next step.

--------------------------------------------------------------
## Step 2. Metadata merging

you'll need:
    - [x] All classifications from Zooniverse: "../zooniverse_classifications/zooniverse_data_all_final.csv"
    - [x] Metadata files: "../metadata/metadata_all_PU.csv"

Open and change paths if needed. 
Run:

$ python merge_datasets_zoon.py 

This will create  XXX.

--------------------------------------------------------------

## Step 3. Segment-chunk conversion

1. Chunk to segment

requirements:
    - [x] result_final="../metadata/result_final_lisa.csv"  #file from PU with segments metadata and lab classifications
    - [x] result_zoon="../metadata/metadata_all_PU.csv"  #metadata for zooniverse clips

Open and change paths if needed. 
Run:

$ python chunk_to_segment.py 


This will create /metadata/dict_4.json file with the mapping between segments and chunks which is used in the next step. 


2. Write_seg_data.py

This routine uses the dictionary mapping to determine chunk-level majority agreement and segment-level classification, then writes to a final file which will be used for the analysis.



you'll need:
    - [x] Dictionary segment-chunk mapping (dict_4.json -- created in the previous step)
    - [x] Classifications + metadata (from Step 2)


Open and change paths if needed. Change output filename on line 87: 

> total.to_csv("classifications_PU_zoon_final_19oct.csv")


Run:

$ python Write_seg_data.py 

This will create  XXX.
