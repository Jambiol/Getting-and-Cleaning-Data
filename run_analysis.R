library(plyr) 
library(data.table)
library(dplyr)

# Download and unzip files
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")
unzip(zipfile="./data/Dataset.zip",exdir="./data")
mypath <- file.path("./data" , "UCI HAR Dataset")
files

# Create variables from files
activitytest  <- read.table(file.path(mypath, "test" , "y_test.txt" ),header = FALSE)
activitytrain <- read.table(file.path(mypath, "train", "y_train.txt"),header = FALSE)
subjecttest  <- read.table(file.path(mypath, "test" , "subject_test.txt"),header = FALSE)
subjecttrain <- read.table(file.path(mypath, "train", "subject_train.txt"),header = FALSE)
featurestest  <- read.table(file.path(mypath, "test" , "X_test.txt" ),header = FALSE)
featurestrain <- read.table(file.path(mypath, "train", "X_train.txt"),header = FALSE)

# Bind rows
subject<- rbind(subjecttrain, subjecttest)
activity <- rbind(activitytrain, activitytest)
features <- rbind(featurestrain, featurestest)

# Name variables
names(subject) <- c("subject")
names(activity) <- c("activity")
featuresnames <- read.table(file.path(mypath, "features.txt"),head=FALSE)
names(features) <- featuresnames$V2

# Merge columns
mergedf <- cbind(subject, activity)
data <- cbind(features, mergedf)

# Subset name of features
subfeaturesnames <- featuresnames$V2[grep("mean\\(\\)|std\\(\\)", featuresnames$V2)]

# Subset data
subsetnames <- c(as.character(subfeaturesnames), "subject", "activity" )
data <- subset(data,select=subsetnames)

# Read descriptive activity names
activitylabels <- read.table(file.path(mypath, "activity_labels.txt"),header = FALSE)

# Appropriately labels the data set with descriptive variable names
names(data) <- gsub("^t", "time", names(data))
names(data) <- gsub("^f", "frequency", names(data))
names(data) <- gsub("Acc", "Accelerometer", names(data))
names(data) <- gsub("Gyro", "Gyroscope", names(data))
names(data) <- gsub("Mag", "Magnitude", names(data))
names(data) <- gsub("BodyBody", "Body", names(data))

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject
data.dt <- data.table(data)
tidydata <- data.dt[, lapply(.SD, mean), by = 'subject,activity']
write.table(tidydata, file = "tidydata.txt", row.names = FALSE)
