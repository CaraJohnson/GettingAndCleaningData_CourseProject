#Class 3 - Getting and Cleaning Data ###Working!
#Course Project


library(reshape2)

#If the working directory does not contain a folder named "data", create it
if(!file.exists("data")) {dir.create("data")}

#download and unzip the zip file containing the datasets to the "data" directory
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/phoneData.zip")
unzip("./data/phoneData.zip",exdir="data",unzip = "internal")


#Load datasets into R
#Subject datasets
subjectTest<-read.table("./data/UCI HAR Dataset/test/subject_test.txt")
xtest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
ytest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")                    

#Training datasets                     
subjectTrain<-read.table("./data/UCI HAR Dataset/train/subject_train.txt")
xtrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
ytrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt")

#Activity and measurement (features) labels
activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
features <- read.table("./data/UCI HAR Dataset/features.txt")


#Prepare the Training and Test datasets
#Assemble the subject ID, measurement variable ID (feature), and data values into single dataset
Train <- cbind(subjectTrain,ytrain,xtrain)
Test <- cbind(subjectTest,ytest,xtest)

#Step 1. Merge datasets together
#Append the Test dataset to the Train dataset, creating one dataset with all data
allData <- rbind(Train,Test)
#assign names to columns of allData
colnames(allData) <- c("subject", "activity", as.character(features[,2]))

#Step 2. Extract only the measurements on the mean and standard deviation for each measurement
#use the grepl() function to create a logical vector indicating which measurement variable names 
#include either "mean" or "std", in addition to the subject and acitvity ID variables
#Use the resulting logical vector to subset allData
temp <- grepl("subject|activity|.*mean.*|.*std.*", names(allData))
allData <- allData[,temp]

#Step 3. Use descriptive activity names to name the activities in the data set
#change the acitvity ID into a factor variable with labels determined by activityLabels
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = as.character(activityLabels[,2]))
#change the subject variable into a factor variable as well
allData$subject <- as.factor(allData$subject)

#Step 4. Appropriately label the data set with descriptive variable names
#Expand all abreviations and remove all () or - characters
names(allData) <- sub("Acc","Accelerometer",names(allData))
names(allData) <- sub("Gyro","Gyroscope",names(allData))
names(allData) <- sub("Mag","Magnitude",names(allData))
names(allData) <- sub("Freq","Frequency",names(allData))
names(allData) <- sub("^t","TimeDomain",names(allData))
names(allData) <- sub("^f","FrequencyDomain",names(allData))
names(allData) <- gsub("-","",names(allData))
names(allData) <- sub("mean","Mean",names(allData))
names(allData) <- sub("std","StandardDeviation",names(allData))
names(allData) <- sub("[-(]","",names(allData))
names(allData) <- sub("[-)]","",names(allData))

#Step 5. From the data set in step 4, create a second, independent tidy data 
#set with the average of each variable for each activity and each subject

#use melt() function to reshape allData to be tall and skinny with, 
#for each subject and activity combination, one row for every measurement value
tidyMelted <- melt(allData, id = c("subject", "activity"))
#use dcast() function to reformat and summarize tidyMelted
#the result is a dataset where each row contains a unique subject/activity 
#combination and the mean of each meausrement
tidyMean <- dcast(tidyMelted, subject + activity ~ variable, mean)

#save the resulting tidy dataset to "data" directory, now ready for any future analysis
write.table(tidyMean, "./data/tidy.txt", row.names = FALSE, quote = FALSE)

