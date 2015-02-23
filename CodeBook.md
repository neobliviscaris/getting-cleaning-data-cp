# CodeBook #

I will describe here the process I followed to construct the data set and transform it in to what I considered
a tidy data set.

### Activity and Feature frames ###
Prep work: configure `activity` and `feature` frames to use for names and labels.  Using the `names()` function, I was able to give meaningful names to the columns of the frame.

This resulted in two data frames: 

activity       | description                                    
---------------|------------------------------------------------
activity_id   | numeric id of the activity (1, 2, etc.)        
activity_label| label as found in the activity_labels.txt file 

feature       | description                                  
--------------|----------------------------------------------
feature_id    | numeric id of the the feature (1, 2, etc.)
feature_label | label as found in the features.txt file

### Test data frame ###

The goal was to build a data frame for the test data with the following structure:

full_test_data     | description                                  
-------------------|:---------------------------------------------
subject_id         | subject id from the subject_test.txt file    
...                | all columns from X_test.txt                  
activity_id        | activity ID from y_test.txt                  
activity_label     | from the above data frame 'activity'         

In order to build the data frame structure above, I read the CSV files and assigned them to variables in the following manner:

* Variable `subject_test` contents loaded from `"test/subject_test.txt"`. 

* Variable `x_test` loaded from `"test/X_test.txt"`. Columns of `x_test` (depicted above as '...') were renamed using the labels in the `feature` data frame the first section.

``` 
 names(x_test) <- feature$feature_label;
```

* Variable `y_test` loaded from `"test/y_test.txt"`. Frame `y_test` was joined with the `activity` frame from the previous section. This introduced actual activity labels into the frame (instead of the IDs only).

```
y_test_with_labels <- join(y_test, activity, by = "activity_id");
```

The full test data frame was constructed using the `cbind()` function.

```
full_test_data <- cbind(subject_test, x_test, y_test_with_labels);
```

Therefore a single row in `full_test_data` would look like this:

subject_test.subject_id  | x_test.* columns  | y_test_with_labels.activity_id | y_test_with_labels.activity_label 
-------------------------|-------------------|--------------------------------|----------------------------------

### Train data frame ###

The goal was to build a data frame for the train data with the following structure:

full_train_data    | description                                   
-------------------|:----------------------------------------------
subject_id         | subject id from the subject_train.txt file    
...                | all columns from X_train.txt                  
activity_id        | activity ID from y_train.txt                  
activity_label     | from the above data frame 'activity'          

In order to build the data frame structure above, I read the CSV files and assigned to variables them in the following manner:

* Variable `subject_train` contents loaded from `"train/subject_train.txt"`. 

* Variable `x_train` loaded from `"train/X_train.txt"`. Columns of `x_train` (depicted above as '...') were renamed using the labels in the `feature` data frame the first section.

``` 
 names(x_train) <- feature$feature_label;
```

* Variable `y_train` loaded from `"train/y_train.txt"`. Frame `y_train` was joined with the `activity` frame from the previous section.  This introduced actual activity labels into the frame (instead of the IDs only).

```
y_train_with_labels <- join(y_train, activity, by = "activity_id");
```

The full train data frame was constructed using the `cbind()` function.

```
full_train_data <- cbind(subject_train, x_train, y_train_with_labels);
```

 Therefore a single row in `full_train_data` would looke like this:

subject_train.subject_id  | x_train.* columns | y_train_with_labels.activity_id | y_train_with_labels.activity_label
--------------------------|-------------------|---------------------------------|-----------------------------------

### Join test and train data frames ###

Once both test and train data sets were complete and had the same columns, I used the `rbind()` function to build one big data set that had the same columns of the test and train data sets.

```
  full_data_set <- rbind(full_train_data, full_test_data);
```

### Include only mean and standard deviation columns ###

After building the full data set, it was necessary to filter out variables and leave in only those for the
`subject_id`, `activity_label`, mean and standard deviation. For that purpose, I used the `grep()` function and a regular
expression of the form `"subject_id|activity_label|mean|std"` to select only the columns I was interested in from the `full_data_set` data frame. This means also the `activity_id` column was dropped from the data frame. The result of the projection of columns was placed in a variable called `data_set_mean_std`.

```
selected_column_names_regex <- "subject_id|activity_label|mean|std";
data_set_mean_std <- full_data_set[, grep(selected_column_names_regex, colnames(full_data_set))];
```

## Building the independent data set ##

Based on the `data_set_mean_std` data frame above, step 5 in the instructions asked us to create an independent data set with a different structure and an additional `mean` column. The next sections describe the steps followed to build such data set.

### One observation per row, part 1: melt ###

After some reading on the Coursera discussion forums, I figured out that I was not following the 'tidy data' principle of having one 'each observation forms a row', since I was having observations for the same subject in multiple rows -see first table below-. This required 'melting' to make my data set 'tall and skinny'.

Basically I started with data frame with this structure (where `v1 ... vN` represent the X test/train variables like `tBodyAcc-mean()-X`):

subject_id  |    v1             | ... |  vN   | activity_label            
------------|:-----------------:|-----|:-----:|:-------------------------
1           |     x             |  y  |  Z    |    WALKING               
1           |     ...           | ... |  ...  |    WALKING_UPSTAIRS       
1           |     ...           | ... |  ...  |    ...
1           |     ...           | ... |  ...  |    LAYING                

In order to simplify my explanation, I will stop using the structure above and use a smaller table with a 'similar' (for the purposes of explaining) structure. `v1` and `v2` represent the myriad of variables (`v1 ... vN` above) taken from the X test/train variables.

subject_id | v1 | v2 | activity_label
----------:|:--:|:--:|:--------------
        1  | -1 | -4 | WALKING       
        1  | -2 | -5 | RUNNING       
        1  | -3 | -6 | LAYING        
        2  |  7 | 10 | WALKING       
        2  |  8 | 11 | RUNNING       
        2  |  9 | 12 | LAYING        

```
 dataMelt <- melt(data_set_mean_std, id=c("subject_id", "activity_label"), measure.vars=setdiff(names(data_set_mean_std), c("subject_id", "activity_label")));
```
The `melt` function I coded used all the `'v1...v2'` column names in the `measure.vars` parameter to the `melt()` call, which I extracted with help of the `setdiff()` (for the difference between two sets) and the `names()` (to get all the column names in a data frame) function.

After applying the `melt` function, the resulting structure is:

subject_id | activity_label |  variable | value
----------:|:--------------:|:---------:|:-----
       1   | WALKING        |  v1       |  -1  
       1   | RUNNING        |  v1       |  -2  
       1   | LAYING         |  v1       |  -3  
       2   | WALKING        |  v1       |   7  
       2   | RUNNING        |  v1       |   8  
       2   | LAYING         |  v1       |   9   
       1   | WALKING        |  v2       |  -4  
       1   | RUNNING        |  v2       |  -5  
       1   | LAYING         |  v2       |  -6  
       2   | WALKING        |  v2       |  10  
       2   | RUNNING        |  v2       |  11  
       2   | LAYING         |  v2       |  12   


### One observation per row, part 2: cast ###

Finally, after the melting, I could do casting. The instruction I used was 

```
dataCast <- dcast(dataMelt, subject_id ~ activity_label + variable);
```

This allowed me to take the data close to its final shape:

subject_id | LAYING_v1 | LAYING_v2 | RUNNING_v1 | RUNNING_v2 | WALKING_v1 | WALKING_v2
----------:|:---------:|:---------:|:----------:|:----------:|:----------:|:----------
         1 |        -3 |        -6 |         -2 |       -5   |       -1   |       -4  
         2 |         9 |        12 |          8 |       11   |        7   |       10  


### Adding the average ###

Instructions for the project required us to add a column "with the average of each variable for each activity and each subject".
I was not sure how to interpret the expression in quotes in the last sentence (and procrastinator me had run out of time to figure it out with the help of the forums) so the only thing that I was able to make out of it was to calculate the average of all activities/readings for the individual, which is effectively the average of columns 2-8 from the structure above this comment.

```
dataCast$mean <- apply(dataCast[,2:ncol(dataCast)], 1, mean, na.rm=TRUE);
```

The result of this `apply()` call is: 

subject_id | LAYING_v1 | LAYING_v2 | RUNNING_v1 | RUNNING_v2 | WALKING_v1 | WALKING_v2 | mean
----------:|:---------:|:---------:|:----------:|:----------:|:----------:|:----------:|------
         1 |        -3 |        -6 |         -2 |       -5   |       -1   |       -4   |  -3.5
         2 |         9 |        12 |          8 |       11   |        7   |       10   |   9.5

The actual result has 476 columns. If we do not consider `subject_id` and `mean`, the number of variables is 474 (depicted as `LAYING_v1`, `LAYING_v2`, in this last table).

### Write output file ###

Finally, I placed the result in a variable `tidy_data` and wrote it to the text file indicated in the instructions.

```
tidy_data <- dataCast;

write.table(tidy_data, file="tidy_data.txt", row.name=FALSE);
```

## Data dictionary for `tidy_data`##

#### subject_id ####
The ID of the subjects whose readings this record represents.

#### <ACTIVITY_LABEL>_<FEATURE_NAME> ####
There are 474 columns (from column 2 to 475) with the above structure. The first section of the column name represents the activity to which the reading is associated. The feature name is the actual type of reading. For example `LAYING_tBodyAcc-mean()-Y` indicates that the corresponding subject was `LAYING` when that particular Y-axis for the body acceleration was measured. The following table lists all the activity-feature variables in the tidy data frame:

Variable name
_______________________________
`LAYING_tBodyAcc-mean()-X`
`LAYING_tBodyAcc-mean()-Y`
`LAYING_tBodyAcc-mean()-Z`
`LAYING_tBodyAcc-std()-X`
`LAYING_tBodyAcc-std()-Y`
`LAYING_tBodyAcc-std()-Z`
`LAYING_tGravityAcc-mean()-X`
`LAYING_tGravityAcc-mean()-Y`
`LAYING_tGravityAcc-mean()-Z`
`LAYING_tGravityAcc-std()-X`
`LAYING_tGravityAcc-std()-Y`
`LAYING_tGravityAcc-std()-Z`
`LAYING_tBodyAccJerk-mean()-X`
`LAYING_tBodyAccJerk-mean()-Y`
`LAYING_tBodyAccJerk-mean()-Z`
`LAYING_tBodyAccJerk-std()-X`
`LAYING_tBodyAccJerk-std()-Y`
`LAYING_tBodyAccJerk-std()-Z`
`LAYING_tBodyGyro-mean()-X`
`LAYING_tBodyGyro-mean()-Y`
`LAYING_tBodyGyro-mean()-Z`
`LAYING_tBodyGyro-std()-X`
`LAYING_tBodyGyro-std()-Y`
`LAYING_tBodyGyro-std()-Z`
`LAYING_tBodyGyroJerk-mean()-X`
`LAYING_tBodyGyroJerk-mean()-Y`
`LAYING_tBodyGyroJerk-mean()-Z`
`LAYING_tBodyGyroJerk-std()-X`
`LAYING_tBodyGyroJerk-std()-Y`
`LAYING_tBodyGyroJerk-std()-Z`
`LAYING_tBodyAccMag-mean()`
`LAYING_tBodyAccMag-std()`
`LAYING_tGravityAccMag-mean()`
`LAYING_tGravityAccMag-std()`
`LAYING_tBodyAccJerkMag-mean()`
`LAYING_tBodyAccJerkMag-std()`
`LAYING_tBodyGyroMag-mean()`
`LAYING_tBodyGyroMag-std()`
`LAYING_tBodyGyroJerkMag-mean()`
`LAYING_tBodyGyroJerkMag-std()`
`LAYING_fBodyAcc-mean()-X`
`LAYING_fBodyAcc-mean()-Y`
`LAYING_fBodyAcc-mean()-Z`
`LAYING_fBodyAcc-std()-X`
`LAYING_fBodyAcc-std()-Y`
`LAYING_fBodyAcc-std()-Z`
`LAYING_fBodyAcc-meanFreq()-X`
`LAYING_fBodyAcc-meanFreq()-Y`
`LAYING_fBodyAcc-meanFreq()-Z`
`LAYING_fBodyAccJerk-mean()-X`
`LAYING_fBodyAccJerk-mean()-Y`
`LAYING_fBodyAccJerk-mean()-Z`
`LAYING_fBodyAccJerk-std()-X`
`LAYING_fBodyAccJerk-std()-Y`
`LAYING_fBodyAccJerk-std()-Z`
`LAYING_fBodyAccJerk-meanFreq()-X`
`LAYING_fBodyAccJerk-meanFreq()-Y`
`LAYING_fBodyAccJerk-meanFreq()-Z`
`LAYING_fBodyGyro-mean()-X`
`LAYING_fBodyGyro-mean()-Y`
`LAYING_fBodyGyro-mean()-Z`
`LAYING_fBodyGyro-std()-X`
`LAYING_fBodyGyro-std()-Y`
`LAYING_fBodyGyro-std()-Z`
`LAYING_fBodyGyro-meanFreq()-X`
`LAYING_fBodyGyro-meanFreq()-Y`
`LAYING_fBodyGyro-meanFreq()-Z`
`LAYING_fBodyAccMag-mean()`
`LAYING_fBodyAccMag-std()`
`LAYING_fBodyAccMag-meanFreq()`
`LAYING_fBodyBodyAccJerkMag-mean()`
`LAYING_fBodyBodyAccJerkMag-std()`
`LAYING_fBodyBodyAccJerkMag-meanFreq()`
`LAYING_fBodyBodyGyroMag-mean()`
`LAYING_fBodyBodyGyroMag-std()`
`LAYING_fBodyBodyGyroMag-meanFreq()`
`LAYING_fBodyBodyGyroJerkMag-mean()`
`LAYING_fBodyBodyGyroJerkMag-std()`
`LAYING_fBodyBodyGyroJerkMag-meanFreq()`
`SITTING_tBodyAcc-mean()-X`
`SITTING_tBodyAcc-mean()-Y`
`SITTING_tBodyAcc-mean()-Z`
`SITTING_tBodyAcc-std()-X`
`SITTING_tBodyAcc-std()-Y`
`SITTING_tBodyAcc-std()-Z`
`SITTING_tGravityAcc-mean()-X`
`SITTING_tGravityAcc-mean()-Y`
`SITTING_tGravityAcc-mean()-Z`
`SITTING_tGravityAcc-std()-X`
`SITTING_tGravityAcc-std()-Y`
`SITTING_tGravityAcc-std()-Z`
`SITTING_tBodyAccJerk-mean()-X`
`SITTING_tBodyAccJerk-mean()-Y`
`SITTING_tBodyAccJerk-mean()-Z`
`SITTING_tBodyAccJerk-std()-X`
`SITTING_tBodyAccJerk-std()-Y`
`SITTING_tBodyAccJerk-std()-Z`
`SITTING_tBodyGyro-mean()-X`
`SITTING_tBodyGyro-mean()-Y`
`SITTING_tBodyGyro-mean()-Z`
`SITTING_tBodyGyro-std()-X`
`SITTING_tBodyGyro-std()-Y`
`SITTING_tBodyGyro-std()-Z`
`SITTING_tBodyGyroJerk-mean()-X`
`SITTING_tBodyGyroJerk-mean()-Y`
`SITTING_tBodyGyroJerk-mean()-Z`
`SITTING_tBodyGyroJerk-std()-X`
`SITTING_tBodyGyroJerk-std()-Y`
`SITTING_tBodyGyroJerk-std()-Z`
`SITTING_tBodyAccMag-mean()`
`SITTING_tBodyAccMag-std()`
`SITTING_tGravityAccMag-mean()`
`SITTING_tGravityAccMag-std()`
`SITTING_tBodyAccJerkMag-mean()`
`SITTING_tBodyAccJerkMag-std()`
`SITTING_tBodyGyroMag-mean()`
`SITTING_tBodyGyroMag-std()`
`SITTING_tBodyGyroJerkMag-mean()`
`SITTING_tBodyGyroJerkMag-std()`
`SITTING_fBodyAcc-mean()-X`
`SITTING_fBodyAcc-mean()-Y`
`SITTING_fBodyAcc-mean()-Z`
`SITTING_fBodyAcc-std()-X`
`SITTING_fBodyAcc-std()-Y`
`SITTING_fBodyAcc-std()-Z`
`SITTING_fBodyAcc-meanFreq()-X`
`SITTING_fBodyAcc-meanFreq()-Y`
`SITTING_fBodyAcc-meanFreq()-Z`
`SITTING_fBodyAccJerk-mean()-X`
`SITTING_fBodyAccJerk-mean()-Y`
`SITTING_fBodyAccJerk-mean()-Z`
`SITTING_fBodyAccJerk-std()-X`
`SITTING_fBodyAccJerk-std()-Y`
`SITTING_fBodyAccJerk-std()-Z`
`SITTING_fBodyAccJerk-meanFreq()-X`
`SITTING_fBodyAccJerk-meanFreq()-Y`
`SITTING_fBodyAccJerk-meanFreq()-Z`
`SITTING_fBodyGyro-mean()-X`
`SITTING_fBodyGyro-mean()-Y`
`SITTING_fBodyGyro-mean()-Z`
`SITTING_fBodyGyro-std()-X`
`SITTING_fBodyGyro-std()-Y`
`SITTING_fBodyGyro-std()-Z`
`SITTING_fBodyGyro-meanFreq()-X`
`SITTING_fBodyGyro-meanFreq()-Y`
`SITTING_fBodyGyro-meanFreq()-Z`
`SITTING_fBodyAccMag-mean()`
`SITTING_fBodyAccMag-std()`
`SITTING_fBodyAccMag-meanFreq()`
`SITTING_fBodyBodyAccJerkMag-mean()`
`SITTING_fBodyBodyAccJerkMag-std()`
`SITTING_fBodyBodyAccJerkMag-meanFreq()`
`SITTING_fBodyBodyGyroMag-mean()`
`SITTING_fBodyBodyGyroMag-std()`
`SITTING_fBodyBodyGyroMag-meanFreq()`
`SITTING_fBodyBodyGyroJerkMag-mean()`
`SITTING_fBodyBodyGyroJerkMag-std()`
`SITTING_fBodyBodyGyroJerkMag-meanFreq()`
`STANDING_tBodyAcc-mean()-X`
`STANDING_tBodyAcc-mean()-Y`
`STANDING_tBodyAcc-mean()-Z`
`STANDING_tBodyAcc-std()-X`
`STANDING_tBodyAcc-std()-Y`
`STANDING_tBodyAcc-std()-Z`
`STANDING_tGravityAcc-mean()-X`
`STANDING_tGravityAcc-mean()-Y`
`STANDING_tGravityAcc-mean()-Z`
`STANDING_tGravityAcc-std()-X`
`STANDING_tGravityAcc-std()-Y`
`STANDING_tGravityAcc-std()-Z`
`STANDING_tBodyAccJerk-mean()-X`
`STANDING_tBodyAccJerk-mean()-Y`
`STANDING_tBodyAccJerk-mean()-Z`
`STANDING_tBodyAccJerk-std()-X`
`STANDING_tBodyAccJerk-std()-Y`
`STANDING_tBodyAccJerk-std()-Z`
`STANDING_tBodyGyro-mean()-X`
`STANDING_tBodyGyro-mean()-Y`
`STANDING_tBodyGyro-mean()-Z`
`STANDING_tBodyGyro-std()-X`
`STANDING_tBodyGyro-std()-Y`
`STANDING_tBodyGyro-std()-Z`
`STANDING_tBodyGyroJerk-mean()-X`
`STANDING_tBodyGyroJerk-mean()-Y`
`STANDING_tBodyGyroJerk-mean()-Z`
`STANDING_tBodyGyroJerk-std()-X`
`STANDING_tBodyGyroJerk-std()-Y`
`STANDING_tBodyGyroJerk-std()-Z`
`STANDING_tBodyAccMag-mean()`
`STANDING_tBodyAccMag-std()`
`STANDING_tGravityAccMag-mean()`
`STANDING_tGravityAccMag-std()`
`STANDING_tBodyAccJerkMag-mean()`
`STANDING_tBodyAccJerkMag-std()`
`STANDING_tBodyGyroMag-mean()`
`STANDING_tBodyGyroMag-std()`
`STANDING_tBodyGyroJerkMag-mean()`
`STANDING_tBodyGyroJerkMag-std()`
`STANDING_fBodyAcc-mean()-X`
`STANDING_fBodyAcc-mean()-Y`
`STANDING_fBodyAcc-mean()-Z`
`STANDING_fBodyAcc-std()-X`
`STANDING_fBodyAcc-std()-Y`
`STANDING_fBodyAcc-std()-Z`
`STANDING_fBodyAcc-meanFreq()-X`
`STANDING_fBodyAcc-meanFreq()-Y`
`STANDING_fBodyAcc-meanFreq()-Z`
`STANDING_fBodyAccJerk-mean()-X`
`STANDING_fBodyAccJerk-mean()-Y`
`STANDING_fBodyAccJerk-mean()-Z`
`STANDING_fBodyAccJerk-std()-X`
`STANDING_fBodyAccJerk-std()-Y`
`STANDING_fBodyAccJerk-std()-Z`
`STANDING_fBodyAccJerk-meanFreq()-X`
`STANDING_fBodyAccJerk-meanFreq()-Y`
`STANDING_fBodyAccJerk-meanFreq()-Z`
`STANDING_fBodyGyro-mean()-X`
`STANDING_fBodyGyro-mean()-Y`
`STANDING_fBodyGyro-mean()-Z`
`STANDING_fBodyGyro-std()-X`
`STANDING_fBodyGyro-std()-Y`
`STANDING_fBodyGyro-std()-Z`
`STANDING_fBodyGyro-meanFreq()-X`
`STANDING_fBodyGyro-meanFreq()-Y`
`STANDING_fBodyGyro-meanFreq()-Z`
`STANDING_fBodyAccMag-mean()`
`STANDING_fBodyAccMag-std()`
`STANDING_fBodyAccMag-meanFreq()`
`STANDING_fBodyBodyAccJerkMag-mean()`
`STANDING_fBodyBodyAccJerkMag-std()`
`STANDING_fBodyBodyAccJerkMag-meanFreq()`
`STANDING_fBodyBodyGyroMag-mean()`
`STANDING_fBodyBodyGyroMag-std()`
`STANDING_fBodyBodyGyroMag-meanFreq()`
`STANDING_fBodyBodyGyroJerkMag-mean()`
`STANDING_fBodyBodyGyroJerkMag-std()`
`STANDING_fBodyBodyGyroJerkMag-meanFreq()`
`WALKING_tBodyAcc-mean()-X`
`WALKING_tBodyAcc-mean()-Y`
`WALKING_tBodyAcc-mean()-Z`
`WALKING_tBodyAcc-std()-X`
`WALKING_tBodyAcc-std()-Y`
`WALKING_tBodyAcc-std()-Z`
`WALKING_tGravityAcc-mean()-X`
`WALKING_tGravityAcc-mean()-Y`
`WALKING_tGravityAcc-mean()-Z`
`WALKING_tGravityAcc-std()-X`
`WALKING_tGravityAcc-std()-Y`
`WALKING_tGravityAcc-std()-Z`
`WALKING_tBodyAccJerk-mean()-X`
`WALKING_tBodyAccJerk-mean()-Y`
`WALKING_tBodyAccJerk-mean()-Z`
`WALKING_tBodyAccJerk-std()-X`
`WALKING_tBodyAccJerk-std()-Y`
`WALKING_tBodyAccJerk-std()-Z`
`WALKING_tBodyGyro-mean()-X`
`WALKING_tBodyGyro-mean()-Y`
`WALKING_tBodyGyro-mean()-Z`
`WALKING_tBodyGyro-std()-X`
`WALKING_tBodyGyro-std()-Y`
`WALKING_tBodyGyro-std()-Z`
`WALKING_tBodyGyroJerk-mean()-X`
`WALKING_tBodyGyroJerk-mean()-Y`
`WALKING_tBodyGyroJerk-mean()-Z`
`WALKING_tBodyGyroJerk-std()-X`
`WALKING_tBodyGyroJerk-std()-Y`
`WALKING_tBodyGyroJerk-std()-Z`
`WALKING_tBodyAccMag-mean()`
`WALKING_tBodyAccMag-std()`
`WALKING_tGravityAccMag-mean()`
`WALKING_tGravityAccMag-std()`
`WALKING_tBodyAccJerkMag-mean()`
`WALKING_tBodyAccJerkMag-std()`
`WALKING_tBodyGyroMag-mean()`
`WALKING_tBodyGyroMag-std()`
`WALKING_tBodyGyroJerkMag-mean()`
`WALKING_tBodyGyroJerkMag-std()`
`WALKING_fBodyAcc-mean()-X`
`WALKING_fBodyAcc-mean()-Y`
`WALKING_fBodyAcc-mean()-Z`
`WALKING_fBodyAcc-std()-X`
`WALKING_fBodyAcc-std()-Y`
`WALKING_fBodyAcc-std()-Z`
`WALKING_fBodyAcc-meanFreq()-X`
`WALKING_fBodyAcc-meanFreq()-Y`
`WALKING_fBodyAcc-meanFreq()-Z`
`WALKING_fBodyAccJerk-mean()-X`
`WALKING_fBodyAccJerk-mean()-Y`
`WALKING_fBodyAccJerk-mean()-Z`
`WALKING_fBodyAccJerk-std()-X`
`WALKING_fBodyAccJerk-std()-Y`
`WALKING_fBodyAccJerk-std()-Z`
`WALKING_fBodyAccJerk-meanFreq()-X`
`WALKING_fBodyAccJerk-meanFreq()-Y`
`WALKING_fBodyAccJerk-meanFreq()-Z`
`WALKING_fBodyGyro-mean()-X`
`WALKING_fBodyGyro-mean()-Y`
`WALKING_fBodyGyro-mean()-Z`
`WALKING_fBodyGyro-std()-X`
`WALKING_fBodyGyro-std()-Y`
`WALKING_fBodyGyro-std()-Z`
`WALKING_fBodyGyro-meanFreq()-X`
`WALKING_fBodyGyro-meanFreq()-Y`
`WALKING_fBodyGyro-meanFreq()-Z`
`WALKING_fBodyAccMag-mean()`
`WALKING_fBodyAccMag-std()`
`WALKING_fBodyAccMag-meanFreq()`
`WALKING_fBodyBodyAccJerkMag-mean()`
`WALKING_fBodyBodyAccJerkMag-std()`
`WALKING_fBodyBodyAccJerkMag-meanFreq()`
`WALKING_fBodyBodyGyroMag-mean()`
`WALKING_fBodyBodyGyroMag-std()`
`WALKING_fBodyBodyGyroMag-meanFreq()`
`WALKING_fBodyBodyGyroJerkMag-mean()`
`WALKING_fBodyBodyGyroJerkMag-std()`
`WALKING_fBodyBodyGyroJerkMag-meanFreq()`
`WALKING_DOWNSTAIRS_tBodyAcc-mean()-X`
`WALKING_DOWNSTAIRS_tBodyAcc-mean()-Y`
`WALKING_DOWNSTAIRS_tBodyAcc-mean()-Z`
`WALKING_DOWNSTAIRS_tBodyAcc-std()-X`
`WALKING_DOWNSTAIRS_tBodyAcc-std()-Y`
`WALKING_DOWNSTAIRS_tBodyAcc-std()-Z`
`WALKING_DOWNSTAIRS_tGravityAcc-mean()-X`
`WALKING_DOWNSTAIRS_tGravityAcc-mean()-Y`
`WALKING_DOWNSTAIRS_tGravityAcc-mean()-Z`
`WALKING_DOWNSTAIRS_tGravityAcc-std()-X`
`WALKING_DOWNSTAIRS_tGravityAcc-std()-Y`
`WALKING_DOWNSTAIRS_tGravityAcc-std()-Z`
`WALKING_DOWNSTAIRS_tBodyAccJerk-mean()-X`
`WALKING_DOWNSTAIRS_tBodyAccJerk-mean()-Y`
`WALKING_DOWNSTAIRS_tBodyAccJerk-mean()-Z`
`WALKING_DOWNSTAIRS_tBodyAccJerk-std()-X`
`WALKING_DOWNSTAIRS_tBodyAccJerk-std()-Y`
`WALKING_DOWNSTAIRS_tBodyAccJerk-std()-Z`
`WALKING_DOWNSTAIRS_tBodyGyro-mean()-X`
`WALKING_DOWNSTAIRS_tBodyGyro-mean()-Y`
`WALKING_DOWNSTAIRS_tBodyGyro-mean()-Z`
`WALKING_DOWNSTAIRS_tBodyGyro-std()-X`
`WALKING_DOWNSTAIRS_tBodyGyro-std()-Y`
`WALKING_DOWNSTAIRS_tBodyGyro-std()-Z`
`WALKING_DOWNSTAIRS_tBodyGyroJerk-mean()-X`
`WALKING_DOWNSTAIRS_tBodyGyroJerk-mean()-Y`
`WALKING_DOWNSTAIRS_tBodyGyroJerk-mean()-Z`
`WALKING_DOWNSTAIRS_tBodyGyroJerk-std()-X`
`WALKING_DOWNSTAIRS_tBodyGyroJerk-std()-Y`
`WALKING_DOWNSTAIRS_tBodyGyroJerk-std()-Z`
`WALKING_DOWNSTAIRS_tBodyAccMag-mean()`
`WALKING_DOWNSTAIRS_tBodyAccMag-std()`
`WALKING_DOWNSTAIRS_tGravityAccMag-mean()`
`WALKING_DOWNSTAIRS_tGravityAccMag-std()`
`WALKING_DOWNSTAIRS_tBodyAccJerkMag-mean()`
`WALKING_DOWNSTAIRS_tBodyAccJerkMag-std()`
`WALKING_DOWNSTAIRS_tBodyGyroMag-mean()`
`WALKING_DOWNSTAIRS_tBodyGyroMag-std()`
`WALKING_DOWNSTAIRS_tBodyGyroJerkMag-mean()`
`WALKING_DOWNSTAIRS_tBodyGyroJerkMag-std()`
`WALKING_DOWNSTAIRS_fBodyAcc-mean()-X`
`WALKING_DOWNSTAIRS_fBodyAcc-mean()-Y`
`WALKING_DOWNSTAIRS_fBodyAcc-mean()-Z`
`WALKING_DOWNSTAIRS_fBodyAcc-std()-X`
`WALKING_DOWNSTAIRS_fBodyAcc-std()-Y`
`WALKING_DOWNSTAIRS_fBodyAcc-std()-Z`
`WALKING_DOWNSTAIRS_fBodyAcc-meanFreq()-X`
`WALKING_DOWNSTAIRS_fBodyAcc-meanFreq()-Y`
`WALKING_DOWNSTAIRS_fBodyAcc-meanFreq()-Z`
`WALKING_DOWNSTAIRS_fBodyAccJerk-mean()-X`
`WALKING_DOWNSTAIRS_fBodyAccJerk-mean()-Y`
`WALKING_DOWNSTAIRS_fBodyAccJerk-mean()-Z`
`WALKING_DOWNSTAIRS_fBodyAccJerk-std()-X`
`WALKING_DOWNSTAIRS_fBodyAccJerk-std()-Y`
`WALKING_DOWNSTAIRS_fBodyAccJerk-std()-Z`
`WALKING_DOWNSTAIRS_fBodyAccJerk-meanFreq()-X`
`WALKING_DOWNSTAIRS_fBodyAccJerk-meanFreq()-Y`
`WALKING_DOWNSTAIRS_fBodyAccJerk-meanFreq()-Z`
`WALKING_DOWNSTAIRS_fBodyGyro-mean()-X`
`WALKING_DOWNSTAIRS_fBodyGyro-mean()-Y`
`WALKING_DOWNSTAIRS_fBodyGyro-mean()-Z`
`WALKING_DOWNSTAIRS_fBodyGyro-std()-X`
`WALKING_DOWNSTAIRS_fBodyGyro-std()-Y`
`WALKING_DOWNSTAIRS_fBodyGyro-std()-Z`
`WALKING_DOWNSTAIRS_fBodyGyro-meanFreq()-X`
`WALKING_DOWNSTAIRS_fBodyGyro-meanFreq()-Y`
`WALKING_DOWNSTAIRS_fBodyGyro-meanFreq()-Z`
`WALKING_DOWNSTAIRS_fBodyAccMag-mean()`
`WALKING_DOWNSTAIRS_fBodyAccMag-std()`
`WALKING_DOWNSTAIRS_fBodyAccMag-meanFreq()`
`WALKING_DOWNSTAIRS_fBodyBodyAccJerkMag-mean()`
`WALKING_DOWNSTAIRS_fBodyBodyAccJerkMag-std()`
`WALKING_DOWNSTAIRS_fBodyBodyAccJerkMag-meanFreq()`
`WALKING_DOWNSTAIRS_fBodyBodyGyroMag-mean()`
`WALKING_DOWNSTAIRS_fBodyBodyGyroMag-std()`
`WALKING_DOWNSTAIRS_fBodyBodyGyroMag-meanFreq()`
`WALKING_DOWNSTAIRS_fBodyBodyGyroJerkMag-mean()`
`WALKING_DOWNSTAIRS_fBodyBodyGyroJerkMag-std()`
`WALKING_DOWNSTAIRS_fBodyBodyGyroJerkMag-meanFreq()`
`WALKING_UPSTAIRS_tBodyAcc-mean()-X`
`WALKING_UPSTAIRS_tBodyAcc-mean()-Y`
`WALKING_UPSTAIRS_tBodyAcc-mean()-Z`
`WALKING_UPSTAIRS_tBodyAcc-std()-X`
`WALKING_UPSTAIRS_tBodyAcc-std()-Y`
`WALKING_UPSTAIRS_tBodyAcc-std()-Z`
`WALKING_UPSTAIRS_tGravityAcc-mean()-X`
`WALKING_UPSTAIRS_tGravityAcc-mean()-Y`
`WALKING_UPSTAIRS_tGravityAcc-mean()-Z`
`WALKING_UPSTAIRS_tGravityAcc-std()-X`
`WALKING_UPSTAIRS_tGravityAcc-std()-Y`
`WALKING_UPSTAIRS_tGravityAcc-std()-Z`
`WALKING_UPSTAIRS_tBodyAccJerk-mean()-X`
`WALKING_UPSTAIRS_tBodyAccJerk-mean()-Y`
`WALKING_UPSTAIRS_tBodyAccJerk-mean()-Z`
`WALKING_UPSTAIRS_tBodyAccJerk-std()-X`
`WALKING_UPSTAIRS_tBodyAccJerk-std()-Y`
`WALKING_UPSTAIRS_tBodyAccJerk-std()-Z`
`WALKING_UPSTAIRS_tBodyGyro-mean()-X`
`WALKING_UPSTAIRS_tBodyGyro-mean()-Y`
`WALKING_UPSTAIRS_tBodyGyro-mean()-Z`
`WALKING_UPSTAIRS_tBodyGyro-std()-X`
`WALKING_UPSTAIRS_tBodyGyro-std()-Y`
`WALKING_UPSTAIRS_tBodyGyro-std()-Z`
`WALKING_UPSTAIRS_tBodyGyroJerk-mean()-X`
`WALKING_UPSTAIRS_tBodyGyroJerk-mean()-Y`
`WALKING_UPSTAIRS_tBodyGyroJerk-mean()-Z`
`WALKING_UPSTAIRS_tBodyGyroJerk-std()-X`
`WALKING_UPSTAIRS_tBodyGyroJerk-std()-Y`
`WALKING_UPSTAIRS_tBodyGyroJerk-std()-Z`
`WALKING_UPSTAIRS_tBodyAccMag-mean()`
`WALKING_UPSTAIRS_tBodyAccMag-std()`
`WALKING_UPSTAIRS_tGravityAccMag-mean()`
`WALKING_UPSTAIRS_tGravityAccMag-std()`
`WALKING_UPSTAIRS_tBodyAccJerkMag-mean()`
`WALKING_UPSTAIRS_tBodyAccJerkMag-std()`
`WALKING_UPSTAIRS_tBodyGyroMag-mean()`
`WALKING_UPSTAIRS_tBodyGyroMag-std()`
`WALKING_UPSTAIRS_tBodyGyroJerkMag-mean()`
`WALKING_UPSTAIRS_tBodyGyroJerkMag-std()`
`WALKING_UPSTAIRS_fBodyAcc-mean()-X`
`WALKING_UPSTAIRS_fBodyAcc-mean()-Y`
`WALKING_UPSTAIRS_fBodyAcc-mean()-Z`
`WALKING_UPSTAIRS_fBodyAcc-std()-X`
`WALKING_UPSTAIRS_fBodyAcc-std()-Y`
`WALKING_UPSTAIRS_fBodyAcc-std()-Z`
`WALKING_UPSTAIRS_fBodyAcc-meanFreq()-X`
`WALKING_UPSTAIRS_fBodyAcc-meanFreq()-Y`
`WALKING_UPSTAIRS_fBodyAcc-meanFreq()-Z`
`WALKING_UPSTAIRS_fBodyAccJerk-mean()-X`
`WALKING_UPSTAIRS_fBodyAccJerk-mean()-Y`
`WALKING_UPSTAIRS_fBodyAccJerk-mean()-Z`
`WALKING_UPSTAIRS_fBodyAccJerk-std()-X`
`WALKING_UPSTAIRS_fBodyAccJerk-std()-Y`
`WALKING_UPSTAIRS_fBodyAccJerk-std()-Z`
`WALKING_UPSTAIRS_fBodyAccJerk-meanFreq()-X`
`WALKING_UPSTAIRS_fBodyAccJerk-meanFreq()-Y`
`WALKING_UPSTAIRS_fBodyAccJerk-meanFreq()-Z`
`WALKING_UPSTAIRS_fBodyGyro-mean()-X`
`WALKING_UPSTAIRS_fBodyGyro-mean()-Y`
`WALKING_UPSTAIRS_fBodyGyro-mean()-Z`
`WALKING_UPSTAIRS_fBodyGyro-std()-X`
`WALKING_UPSTAIRS_fBodyGyro-std()-Y`
`WALKING_UPSTAIRS_fBodyGyro-std()-Z`
`WALKING_UPSTAIRS_fBodyGyro-meanFreq()-X`
`WALKING_UPSTAIRS_fBodyGyro-meanFreq()-Y`
`WALKING_UPSTAIRS_fBodyGyro-meanFreq()-Z`
`WALKING_UPSTAIRS_fBodyAccMag-mean()`
`WALKING_UPSTAIRS_fBodyAccMag-std()`
`WALKING_UPSTAIRS_fBodyAccMag-meanFreq()`
`WALKING_UPSTAIRS_fBodyBodyAccJerkMag-mean()`
`WALKING_UPSTAIRS_fBodyBodyAccJerkMag-std()`
`WALKING_UPSTAIRS_fBodyBodyAccJerkMag-meanFreq()`
`WALKING_UPSTAIRS_fBodyBodyGyroMag-mean()`
`WALKING_UPSTAIRS_fBodyBodyGyroMag-std()`
`WALKING_UPSTAIRS_fBodyBodyGyroMag-meanFreq()`
`WALKING_UPSTAIRS_fBodyBodyGyroJerkMag-mean()`
`WALKING_UPSTAIRS_fBodyBodyGyroJerkMag-std()`
`WALKING_UPSTAIRS_fBodyBodyGyroJerkMag-meanFreq()`

#### mean ####
The average of all activities/readings for the subject associated to this record.
