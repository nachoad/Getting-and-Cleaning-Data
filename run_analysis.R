################################################################
## Note:                                                      ##
##  All the script has been commented in the README.md file   ##
################################################################

# setwd("~/PERSONAL/COURSERA/GETTING_AND_CLEANING_DATA/FinalProject/n")

######################
## DATA PREPARATION ##
######################

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

unzip(zipfile="./data/Dataset.zip",exdir="./data")

path_rf <- file.path("./data" , "UCI HAR Dataset")
files <- list.files(path_rf, recursive=TRUE)
files

dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ), header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "y_train.txt"), header = FALSE)
## Just cheking...
# nrow(dataActivityTest)+nrow(dataActivityTrain) * 0.7  
## Should be aprox equal to num of observations of dataActivityTrain
# nrow(dataActivityTest)+nrow(dataActivityTrain) * 0.3
## Should be aprox equal to num of observations of dataActivityTest

dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"), header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"), header = FALSE)

dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ), header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"), header = FALSE)
# View(dataFeaturesTest)

featuresNames <- read.table(file.path(path_rf, "features.txt"), header = FALSE)
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt" ), header = FALSE)

# str(dataActivityTest)
# str(dataActivityTrain)
# str(dataSubjectTrain)
# str(dataSubjectTest)
# str(dataFeaturesTest)
# str(dataFeaturesTrain)

############
## PART 1 ##
############

dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

names(dataSubject) <- c("subject")
names(dataActivity) <- c("activity")
names(dataFeatures) <- featuresNames$V2

Data <- cbind(dataFeatures, dataSubject, dataActivity)

############
## PART 2 ##
############

columnsWithMeanSTD <- grep(".*Mean.*|.*Std.*", names(Data), ignore.case=TRUE)
requiredColumns <- c(562, 563, columnsWithMeanSTD)
dim(Data)
extractedData <- Data[,requiredColumns]
dim(extractedData)
str(extractedData)

############
## PART 3 ##
############

extractedData$activity <- as.character(extractedData$activity)
for (i in 1:6){
  extractedData$activity[extractedData$activity == i] <- as.character(activityLabels[i,2])
}

extractedData$activity <- as.factor(extractedData$activity)
# checking...
head(extractedData$activity,40)

############
## PART 4 ##
############

names(extractedData)

names(extractedData) <- gsub("^t", "Time", names(extractedData))
names(extractedData) <- gsub("^f", "Frequency", names(extractedData))
names(extractedData) <- gsub("Acc", "Accelerometer", names(extractedData))
names(extractedData) <- gsub("Gyro", "Gyroscope", names(extractedData))
names(extractedData) <- gsub("Mag", "Magnitude", names(extractedData))
names(extractedData) <- gsub("BodyBody", "Body", names(extractedData))

#checking...
names(extractedData)

############
## PART 5 ##
############

library(plyr);
tidyData<-aggregate(. ~subject + activity, extractedData, mean)
tidyData<-tidyData[order(tidyData$subject,tidyData$activity),]
write.table(tidyData, file = "tidy_data.txt", row.name=FALSE)

