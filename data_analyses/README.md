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

## Step 3. Combine the new chunk metadata file with all the other information

This is done in R, code called `generate_jslhr_data.R`, inside `202010_jslhr`. Please see comments in there.

