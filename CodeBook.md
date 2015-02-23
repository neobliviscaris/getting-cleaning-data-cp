# CodeBook #

I will describe here the process I followed to construct the data set and transform it in to what I considered
a tidy data set.

### Activity and Feature frames ###
Prep work: configure activity and feature frames to use for names and labels.

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

Build a data frame for the test data with the following structure

full_test_data     | description                                  
-------------------|:---------------------------------------------
subject_id         | subject id from the subject_test.txt file    
...                | all columns from X_test.txt                  
activity_id        | activity ID from y_test.txt                  
activity_label     | from the above data frame 'activity'         

 Columns above depicted as '...' were renamed using the labels in the 'feature' data frame from point 1.

``` 
 names(x_test) <- feature$feature_label;
```

 Therefore a single row would look like this:

 | subject_test.subject_id  | ... x_test.* columns ... | ... y_test.activity_id activity.activity_label   |
 |--------------------------|:------------------------:|:------------------------------------------------:|

### Train data frame ###

Build a data frame for the train data with the following structure

 | full_train_data    | description                                     |
 |--------------------|:-----------------------------------------------:|
 | subject_id         | subject id from the subject_train.txt file      |
 | ...                | all columns from X_train.txt                    |
 | activity_id        | activity ID from y_train.txt                    |
 | activity_label     | from the above data frame 'activity'            |

 Columns above depicted as '...' were renamed using the labels in the 'feature' data frame from point 1.

```
 names(x_train) <- feature$feature_label;
```

 Therefore a single row in full_train_data would looke like this:

 | subject_train.subject_id  | ... x_train.* columns ... | ... y_train.activity_id  | activity.activity_label |
 |---------------------------|:-------------------------:|:------------------------:|:-----------------------:|

### Join test and train data frames ###

Once both data sets were in place, I used the rbind function to build one big data set
  that had the same columns of the test and train data sets

```
  full_data_set <- rbind(full_train_data, full_test_data);
```

### Include only mean and standard deviation columns ###

After building the full data set, it was necessary to filter out variables and leave in only those for the
subject_id, activity_label, mean and standard deviation. For that purpose, I used the grep() function and a regular
expression of the form "subject_id|activity_label|mean|std" to select only the columns I was interested in from the full_data_set data frame. This means also the activity_id column was dropped from the data frame. The result of the projection of columns was placed in a variable called data_set_mean_std.

### One observation per row, part 1: melt ###

After some reading on the Coursera discussion forums, I figured out that I was not following the 'tidy data' principle of having one 'each observation forms a row', since I was having observations for the same subject in multiple rows. This required 'melting' to make my data set 'tall and skinny'.

Basically I went from a data frame with this structure (where v1 ... vN represent the X test/train variables like 'tBodyAcc-mean()-X'):

 | subject_id  |    v1             | ... |  vN   | activity_label               |
 |-------------|:-----------------:|-----|:-----:|:----------------------------:|
 | 1           |     x             |  y  |  Z    |    WALKING                   |
 | 1           |     ...           | ... |  ...  |    WALKING_UPSAIRS           |
 | 1           |     ...           | ... |  ...  |                              |
 | 1           |     ...           | ... |  ...  |    LAYING                    |

In order to simplify my explanation, I will stop using the structure above and use a smaller table with a 'similar' (for the purposes of explaining) structure. v1 and v2 represent the myriad of variables (v1 ... vN above) taken from the X test/train variables.

 | subject_id | v1 | v2 | activity_label |
 |:----------:|:--:|:--:|:--------------:|
 |         1  | -1 | -4 | WALKING        |
 |         1  | -2 | -5 | RUNNING        |
 |         1  | -3 | -6 | LAYING         |
 |         2  |  7 | 10 | WALKING        |
 |         2  |  8 | 11 | RUNNING        |
 |         2  |  9 | 12 | LAYING         |

After applying the melt function, the resulting structure is:

 | subject_id | activity_label |  variable | value |
 |:----------:|:--------------:|:---------:|:-----:|
 |        1   | WALKING        |  v1       |  -1   |
 |        1   | RUNNING        |  v1       |  -2   |
 |        1   | LAYING         |  v1       |  -3   |
 |        2   | WALKING        |  v1       |   7   |
 |        2   | RUNNING        |  v1       |   8   |
 |        2   | LAYING         |  v1       |   9   | 
 |        1   | WALKING        |  v2       |  -4   |
 |        1   | RUNNING        |  v2       |  -5   |
 |        1   | LAYING         |  v2       |  -6   |
 |        2   | WALKING        |  v2       |  10   |
 |        2   | RUNNING        |  v2       |  11   |
 |        2   | LAYING         |  v2       |  12   | 

 The melt function I used used all the 'v1...v2' column names in the measure.vars parameter to the melt() call, which I extracted with help of the setdiff (for the difference between two sets) and the names (to get all the column names in a data frame) function.

```
 dataMelt <- melt(data_set_mean_std, id=c("subject_id", "activity_label"), measure.vars=setdiff(names(data_set_mean_std), c("subject_id", "activity_label")));
```
### One observation per row, part 2: cast ###

Finally, after the melting, I could do casting. This allowed me to take the data close to its final shape:

 | subject_id | LAYING_v1 | LAYING_v2 | RUNNING_v1 | RUNNING_v2 | WALKING_v1 | WALKING_v2 |
 |:----------:|:---------:|:---------:|:----------:|:----------:|:----------:|:----------:|
 |          1 |        -3 |        -6 |         -2 |       -5   |       -1   |       -4   |
 |          2 |         9 |        12 |          8 |       11   |        7   |       10   |

The instruction I used was 

```
dataCast <- dcast(dataMelt, subject_id ~ activity_label + variable);
```

### Adding the average ###

Instructions for the project required us to add a column "with the average of each variable for each activity and each subject".
I was not sure how to interpret the expression in quotes in the last sentence (an procrastinator me had run out of time to figure out through the forums) so the only thing that I was able to make out of it was to calculate the average of all activities/readings for the individual, which is effectively the average of columns 2-8 from the structure above this comment.

```
dataCast$mean <- apply(dataCast[,2:ncol(dataCast)], 1, mean, na.rm=TRUE);
```

### Write output file ###

Finally, I placed the result in a variable 'tidy_data' and wrote it to the text file indicated in the instructions.

```
tidy_data <- dataCast;

write.table(tidy_data, file="tidy_data.txt", row.name=FALSE);
```
