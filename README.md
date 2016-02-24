---
title: "Getting and cleaning data project"
---

This is an R Markdown document with my scripts to solve the "Getting and cleaning data project" of Coursera course.

The first step is loading the packages to be used

```{r}
library(plyr) 
library(data.table)
library(dplyr)
```

We create a directory where we download and unzip the data. 

```{r}
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")
unzip(zipfile="./data/Dataset.zip",exdir="./data")
mypath <- file.path("./data" , "UCI HAR Dataset")
```

We create variables from reading the files that we downloaded

```{r}
activitytest <- read.table(file.path(mypath, "test" , "y_test.txt" ), header = FALSE)
activitytrain <- read.table(file.path(mypath, "train", "y_train.txt"), header = FALSE)
subjecttest  <- read.table(file.path(mypath, "test" , "subject_test.txt"), header = FALSE)
subjecttrain <- read.table(file.path(mypath, "train", "subject_train.txt"), header = FALSE)
featurestest  <- read.table(file.path(mypath, "test" , "X_test.txt" ), header = FALSE)
featurestrain <- read.table(file.path(mypath, "train", "X_train.txt"), header = FALSE)
```

We bind rows to merge train and test sets

```{r}
subject <- rbind(subjecttrain, subjecttest)
activity <- rbind(activitytrain, activitytest)
features <- rbind(featurestrain, featurestest)
```

We set the name of the variables

```{r}
names(subject) <- c("subject")
names(activity) <- c("activity")
featuresnames <- read.table(file.path(mypath, "features.txt"),head=FALSE)
names(features) <- featuresnames$V2
```

We merge the training and the test sets to create one data set

```{r}
mergedf <- cbind(subject, activity)
data <- cbind(features, mergedf)
```

We subset the names of the measurements on the mean and standard deviation for each measurement

```{r}
meanstdnames <- featuresnames$V2[grep("mean\\(\\)|std\\(\\)", featuresnames$V2)])
```


We subset only the measurements on the mean and standard deviation for each measurement

```{r}
subsetnames <- c(as.character(meanstdnames), "subject", "activity" )
data <- subset(data, select=subsetnames)
```

We read descriptive activity names from the .txt file

```{r}
activitylabels <- read.table(file.path(mypath, "activity_labels.txt"), header = FALSE)
```

We use descriptive activity names to name the activities in the data set

```{r}
data$activity <- activitylabels$V2[data$activity]
```

We appropriately label the data set with descriptive variable names
```{r}
names(data) <- gsub("^t", "time", names(data))
names(data) <- gsub("^f", "frequency", names(data))
names(data) <- gsub("Acc", "Accelerometer", names(data))
names(data) <- gsub("Gyro", "Gyroscope", names(data))
names(data) <- gsub("Mag", "Magnitude", names(data))
names(data) <- gsub("BodyBody", "Body", names(data))
```

We create the final tdy data set with the average of each variable for each activity and each subject

```{r}
grouped <- data %>% group_by(activity, subject)
tidydata <- grouped %>% summarise_each(funs(mean))
```


Finally, we create a .txt file with tidydata
```{r}
write.table(tidydata, file = "tidydata.txt", row.names = FALSE)
```

