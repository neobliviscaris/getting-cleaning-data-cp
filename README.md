 # Getting and Cleaning Data, Course Project # 

 This repository contains the following files:

- run_analysis.R: The script described in the course project page.

 This file assumes it is being run inside the "UCI HAR Dataset" folder resulting
 from unzipping the provided 'getdata-projectfiles-UCI HAR Dataset.zip'
 Also, it assumes the presence of the 'test' and 'train' folders 
 containing:

 activity_labels.txt
 features.txt

 test/subject_test.txt
 test/X_test.txt
 test/y_test.txt

 train/subject_train.txt
 train/X_train.txt
 train/y_train.txt

 Upon execution, the script will output a file (which I also posted to the Coursera website as per the instructions) called 'tidy_data.txt'. The end result is in tidy_data. It will have 30 rows with 476 columns each.

- CodeBook.md: Notes describing the variables, data, and any transformations or work performed to clean up the data.

## How to run ##

Make sure the script is inside the "UCI HAR Dataset" directory and can use relative references (as opposed to full paths, i.e. "features.txt" instead of "/some/path/to/USI HAR Dataset/features.txt") to the files in the dataset