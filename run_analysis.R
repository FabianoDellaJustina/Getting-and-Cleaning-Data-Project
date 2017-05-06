###Setting the work directory:
setwd("C:/Data/Data Science Specialization/3.Getting and Cleaning Data/Course Project/getdata/UCI_HAR_Dataset")


### Setting Libraries: 

library(plyr)
library(data.table)

### i) Merging the training and the test sets to create one data set:

## Reading the raw data:

# training data

subjectTrain <- read.table("train/subject_train.txt", header = FALSE)
yTrain       <- read.table("train/y_train.txt", header = FALSE)
xTrain       <- read.table("train/X_train.txt", header = FALSE)

# testing data

subjectTest <- read.table("test/subject_test.txt", header = FALSE)
yTest       <- read.table("test/y_test.txt", header = FALSE)
xTest       <- read.table("test/X_test.txt", header = FALSE)


## Setting the data

subject  <- rbind(subjectTrain, subjectTest)
activity <- rbind(yTrain, yTest)
features <- rbind(xTrain, xTest)

## Giving suitable names

featureNames       <- read.table("features.txt")
activityLabels     <- read.table("activity_labels.txt", header = FALSE)
colnames(features) <- t(featureNames[2])

## Merged data

colnames(activity) <- "Activity"
colnames(subject)  <- "Subject"
PreProcData        <- cbind(features,activity,subject)

### ii) Extracting only the measurements on the mean and standard deviation for each measurement:

MeanStd <- grep(".*Mean.*|.*Std.*", names(PreProcData), ignore.case=TRUE)
Columns <- c(MeanStd, 562, 563)
Data    <- PreProcData[,Columns]

### iii) Using descriptive activity names to name the activities in the data set:

Data$Activity <- as.character(Data$Activity)
for (i in 1:6){
           Data$Activity[Data$Activity == i] <- as.character(activityLabels[i,2])
       }
Data$Activity <- as.factor(Data$Activity)


### iv) giving appropriately labels the data set with descriptive variable names:

names(Data) <- gsub("Acc", "Accelerometer", names(Data))
names(Data) <- gsub("Gyro", "Gyroscope", names(Data))
names(Data) <- gsub("BodyBody", "Body", names(Data))
names(Data) <- gsub("Mag", "Magnitude", names(Data))
names(Data) <- gsub("^t", "Time", names(Data))
names(Data) <- gsub("^f", "Frequency", names(Data))
names(Data) <- gsub("tBody", "TimeBody", names(Data))
names(Data) <- gsub("-mean()", "Mean", names(Data), ignore.case = TRUE)
names(Data) <- gsub("-std()", "STD", names(Data), ignore.case = TRUE)
names(Data) <- gsub("-freq()", "Frequency", names(Data), ignore.case = TRUE)
names(Data) <- gsub("angle", "Angle", names(Data))
names(Data) <- gsub("gravity", "Gravity", names(Data))

### v) creating a second, independent tidy data set with the average of each variable for each activity and each subject:

Data$Subject <- as.factor(Data$Subject)
Data         <- data.table(Data)
ProcData     <- aggregate(. ~Subject + Activity, Data, mean)
ProcData     <- ProcData[order(ProcData$Subject,ProcData$Activity),]
write.table(ProcData, file = "TidyData.txt", row.names = FALSE)



