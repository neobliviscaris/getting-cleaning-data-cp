# File run_analysis.R
# This file assumes it is being run inside the "UCI HAR Dataset" folder resulting
# from unzipping the provided 'getdata-projectfiles-UCI HAR Dataset.zip'
# It assumes the presence of the 'test' and 'train' folders 
# containing:
#
# activity_labels.txt
# features.txt
#
# test/subject_test.txt
# test/X_test.txt
# test/y_test.txt
#
# train/subject_train.txt
# train/X_train.txt
# train/y_train.txt


library(plyr); 
library(dplyr);
library(reshape2);

# Prep work: configure activity and feature frames to use for names and labels
activity <- read.csv("activity_labels.txt", header = FALSE, sep = "");
names(activity) <- c("activity_id","activity_label");

feature <- read.csv("features.txt", header = FALSE, sep = "");
names(feature) <- c("feature_id", "feature_label");

#####################################################################################################
# Merges the training and the test sets to create one data set.
#    Build a full test data frame
#    Build a full train data frame

#####################################################################################################
# Full test data Frame
# Columns:
# subject_test.subject_id | ... x_test.* columns ... | ... y_test.activity_id activity.activity_label
subject_test <- read.csv("test//subject_test.txt", header = FALSE, sep = "");
names(subject_test) <- c("subject_id");

x_test <- read.csv("test//X_test.txt", header = FALSE, sep = "");
# Appropriately labels the data set with descriptive variable names. 
names(x_test) <- feature$feature_label;

y_test <- read.csv("test//y_test.txt", header = FALSE, sep = "");
names(y_test) <- c("activity_id")
# Uses descriptive activity names to name the activities in the data set
y_test_with_labels <- join(y_test, activity, by = "activity_id");

full_test_data <- cbind(subject_test, x_test, y_test_with_labels);

#####################################################################################################
# Full train data frame
# Columns:
# subject_train.subject_id | ... x_train.* columns ... | ... y_train.activity_id activity.activity_label
subject_train <- read.csv("train//subject_train.txt", header = FALSE, sep = "");
names(subject_train) <- c("subject_id");

x_train <- read.csv("train//X_train.txt", header = FALSE, sep = "");
# Appropriately labels the data set with descriptive variable names. 
names(x_train) <- feature$feature_label;

y_train <- read.csv("train//y_train.txt", header = FALSE, sep = "");
names(y_train) <- c("activity_id")
# Uses descriptive activity names to name the activities in the data set
y_train_with_labels <- join(y_train, activity, by = "activity_id");

full_train_data <- cbind(subject_train, x_train, y_train_with_labels);

#####################################################################################################
# Full merged data set
full_data_set <- rbind(full_train_data, full_test_data);

#####################################################################################################
# Full merged data set only mean and standard deviation
selected_column_names_regex <- "subject_id|activity_label|mean|std";
data_set_mean_std <- full_data_set[, grep(selected_column_names_regex, colnames(full_data_set))];

# From the data set above, creates a second, independent tidy data 
#    set with the average of each variable for each activity and each subject.
#
# We start with a structure like the following. Where v1 and v2 are all the x_train and x_test variables
# such as fBody...mean()-X, etc. I am using only WALKING, RUNNING, and LAYING, to simplify my exmaple.
#
# subject_id   v1  v2  activity_label
# -------------------------------
#          1   -1  -4  WALKING
#          1   -2  -5  RUNNING
#          1   -3  -6  LAYING
#          2    7  10  WALKING
#          2    8  11  RUNNING
#          2    9  12  LAYING

dataMelt <- melt(data_set_mean_std, id=c("subject_id", "activity_label"), measure.vars=setdiff(names(data_set_mean_std), c("subject_id", "activity_label")));
# After applying melt, we end up with the following structure:
# subject_id  activity_label   variable  value
#         1   WALKNIG          v1        -1
#         1   RUNNING          v1        -2
#         1   LAYING           v1        -3
#         2   WALKING          v1         7
#         2   RUNNING          V1         8
#         2   LAYING           V1         9
#         1   WALKING          V2        -4
#         1   RUNNING          V2        -5
#         1   LAYING           V2        -6
#         2   WALKING          V2        10
#         2   RUNNING          V2        11
#         2   LAYING           V2        12

dataCast <- dcast(dataMelt, subject_id ~ activity_label + variable);
# After applying the dcast function, we end up with the following structure:
# subject_id  LAYING_v1  LAYING_v2  RUNNING_v1  RUNNING_v2  WALKING_v1  WALKING_v2
#          1         -3         -6          -2          -5          -1          -4
#          2          9         12           8          11           7          10

# I am not too sure about the "with the average of each variable for each activity and each subject"
# but this is the only thing that I was able to make out of it: the average of all activities/readings for
# the individual, which is effectively the average of columns 2-8 from the structure above this comment.
dataCast$mean <- apply(dataCast[,2:ncol(dataCast)], 1, mean, na.rm=TRUE);
# This results in the following structure:
# subject_id  LAYING_v1  LAYING_v2  RUNNING_v1  RUNNING_v2  WALKING_v1  WALKING_v2  mean
#          1         -3         -6          -2          -5          -1          -4  -3.5
#          2          9         12           8          11           7          10   9.5
# The end result is in tidy_data. It will have 30 rows with 476 columns each.
tidy_data <- dataCast;

write.table(tidy_data, file="tidy_data.txt", row.name=FALSE);
