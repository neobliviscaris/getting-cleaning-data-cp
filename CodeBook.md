# CodeBook #

I will describe here the process I followed to construct the data set and transform it in to what I considered
a tidy data set.

1. Prep work: configure activity and feature frames to use for names and labels.
 This resulted in two data frames: 

 |activity       | description                                    |
 |---------------|:----------------------------------------------:|
 | activity_id   | numeric id of the activity (1, 2, etc.)        |
 | activity_label| label as found in the activity_labels.txt file |

 |feature        | description                                    |
 |---------------|:----------------------------------------------:|
 | feature_id    | numeric id of the the feature (1, 2, etc.)     |
 | feature_label | label as found in the features.txt file        |

2. Build a data frame for the test data with the following structure

 | full_test_data     | description                                    |
 |--------------------|:----------------------------------------------:|
 | subject_id         | subject id from the subject_test.txt file      |
 | ...                | all columns from X_test.txt                    |
 | activity_id        | activity ID from y_test.txt                    |
 | activity_label     | from the above data frame 'activity'           |

 Columns above depicted as '...' were renamed using the labels in the 'feature' data frame from point 1.
 names(x_test) <- feature$feature_label;

 Therefore a single row would look like this:
 subject_test.subject_id | ... x_test.* columns ... | ... y_test.activity_id activity.activity_label

3. Build a data frame for the train data with the following structure

 | full_train_data     | description                                    |
 |--------------------|:-----------------------------------------------:|
 | subject_id         | subject id from the subject_train.txt file      |
 | ...                | all columns from X_train.txt                    |
 | activity_id        | activity ID from y_train.txt                    |
 | activity_label     | from the above data frame 'activity'            |

 Columns above depicted as '...' were renamed using the labels in the 'feature' data frame from point 1.
 names(x_train) <- feature$feature_label;

 Therefore a single row in full_train_data would looke like this:
 subject_train.subject_id | ... x_train.* columns ... | ... y_train.activity_id activity.activity_label

4. Once both data sets were in place, I used the rbind function to build one big data set
  that had the same columns of the test and train data sets
  full_data_set <- rbind(full_train_data, full_test_data);

5. 