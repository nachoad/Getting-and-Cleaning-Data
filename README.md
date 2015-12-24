# Getting and Cleaning Data Course Assignment
#### 24 Dec, 2015
#### Autor: Ignacio Alonso Delgado

## Introduction
  
  The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected. 
  
  One of the most exciting areas in all of data science right now is wearable computing - see for example [this article](http://www.insideactivitytracking.com/data-science-activity-tracking-and-the-battle-for-the-worlds-top-sports-brand/). Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 
  

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project: 

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Good luck!

## Files on this repo:
  
- *run_analysis.R* : the R-code run on the data set
- *tidy_data.txt* : the clean data extracted from the original data using *run_analysis.R*
- *CodeBook.md* : the CodeBook reference to the variables in *tidy_data.txt*
- *README.md* : the analysis of the code in *run_analysis.R*
- *README.html* : the html version of *README.md* that can be accessed at https://github.com/nachoad/Getting-and-Cleaning-Data/blob/master/README.html
  
## Getting Started
  
### Get the data
1. Download the file and put the file in the `data` folder
```r
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")
```

2. Unzip the file
```r
unzip(zipfile="./data/Dataset.zip",exdir="./data")
```

3. Unzipped files are in the folder `UCI HAR Dataset. Get the list of the files
```r
ath_rf <- file.path("./data" , "UCI HAR Dataset")
files <- list.files(path_rf, recursive=TRUE)
files
```

The files that will be used to load data are listed as follows:

- test/subject_test.txt
- test/X_test.txt
- test/y_test.txt
- train/subject_train.txt
- train/X_train.txt
- train/y_train.txt

4. Read data from the files into the variables

Read the Activity files
```r
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ), header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"), header = FALSE)
```

Read the Subject files
```r
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"), header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"), header = FALSE)
```

Read Features files
```r
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ), header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"), header = FALSE)
```

Read the `Features Names`, and `ActivityLabels`
```r
featuresNames <- read.table(file.path(path_rf, "features.txt"), header = FALSE)
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt" ), header = FALSE)
```

5. Look at the properties of the above varibles
```r
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)
```

## Part 1 - Merge the training and the test sets to create one data set.

1. Concatenate the data tables by rows
```r
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
```

2. Set names to variables
```r
names(dataSubject) <- c("subject")
names(dataActivity) <- c("activity")
names(dataFeatures) <- dataFeaturesNames$V2
```

3. Merge columns to get the data frame Data for all data
```r
Data <- cbind(dataFeatures, dataSubject, dataActivity)
```

## Part 2 - Extracts only the measurements on the mean and standard deviation for each measurement.

Extract the column indices that have either mean or std in them.
```r
columnsWithMeanSTD <- grep(".*Mean.*|.*Std.*", names(Data), ignore.case=TRUE)
```
Add activity and subject columns to the list and look at the dimension of `Data`.
```r
requiredColumns <- c(562, 563, columnsWithMeanSTD)
dim(Data)
```
Create extractedData with the selected columns in `requiredColumns`. 
```r
extractedData <- Data[,requiredColumns]
dim(extractedData)
str(extractedData)
```

## Part 3 - Uses descriptive activity names to name the activities in the data set.
The activity field in `extractedData` is originally of numeric type. We need to change its type to character so that it can accept activity names. The activity names are taken from metadata `activityLabels`.
```r
extractedData$activity <- as.character(extractedData$activity)
for (i in 1:6){
extractedData$activity[extractedData$Activity == i] <- as.character(activityLabels[i,2])
}
```

We need to factor the activity variable, once the activity names are updated.
```r
extractedData$activity <- as.factor(extractedData$activity)
```
Checking:
```r
head(extractedData$activity,40)
```

## Part 4 - Appropriately labels the data set with descriptive variable names.
Here are the names of the (88) variables filtered in `extractedData`.
```r
names(extractedData)
```

Names of Feteatures will labelled using descriptive variable names.

- letter `t` is replaced by `time`
- `Acc` is replaced by `Accelerometer`
- `Gyro` is replaced by `Gyroscope`
- letter `f` is replaced by `Frequency`
- `Mag` is replaced by `Magnitude`
- `BodyBody` is replaced by `Body`

```r
names(extractedData) <- gsub("^t", "Time", names(extractedData))
names(extractedData) <- gsub("^f", "Frequency", names(extractedData))
names(extractedData) <- gsub("Acc", "Accelerometer", names(extractedData))
names(extractedData) <- gsub("Gyro", "Gyroscope", names(extractedData))
names(extractedData) <- gsub("Mag", "Magnitude", names(extractedData))
names(extractedData) <- gsub("BodyBody", "Body", names(extractedData))
```

Checking:
```r
names(extractedData)
```

## Part 5 - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
Create tidyData as a data set with average for each activity and subject. Then, we order the enties in tidyData and write it into data file Tidy.txt that contains the processed data.
```r
library(plyr);
tidyData<-aggregate(. ~subject + activity, extractedData, mean)
tidyData<-tidyData[order(tidyData$subject,tidyData$activity),]
write.table(tidyData, file = "tidy_data.txt",row.name=FALSE)
```

#### V.1.0
