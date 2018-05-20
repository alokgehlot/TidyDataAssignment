#Download and unzip the dataset:
 
url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(url,"UCI_HAR_DataSet.zip",mode="wb")

unzip("UCI_HAR_DataSet.zip")

#Load activity_labels.txt and features.txt as tables

activity_labels<-read.table("UCI HAR Dataset/activity_labels.txt")

features<-read.table("UCI HAR Dataset/features.txt")

activity_labels[,2]<-as.character(activity_labels[,2])

features[,2]<-as.character(features[,2])

#Extracts only the measurements on the mean and standard deviation for each measurement

DesiredFeatures<-grep(".*mean.*|.*std.*",features[,2])
DesiredFeatures.names<-features[DesiredFeatures,2]
DesiredFeatures.names<-gsub('-mean','Mean',DesiredFeatures.names)
DesiredFeatures.names=gsub('-std','Std',DesiredFeatures.names)
DesiredFeatures.names<-gsub('[-()]','',DesiredFeatures.names)

#Load the training datasets, training lables and subject
xtrain<-read.table("UCI HAR DataSet/train/X_train.txt")[DesiredFeatures]
ytrain<-read.table("UCI HAR DataSet/train/Y_train.txt")
subjecttrain<-read.table("UCI HAR DataSet/train/subject_train.txt")

#Merge Training dataset, Activities and Subjects
trainData<-cbind(subjecttrain,ytrain,xtrain)

#Load the testing datasets, testing lables and subject
xtest<-read.table("UCI HAR DataSet/test/X_test.txt")[DesiredFeatures]
ytest<-read.table("UCI HAR DataSet/test/Y_test.txt")
subjecttest<-read.table("UCI HAR DataSet/test/subject_test.txt")

#Merge Testing dataset, Activities and Subjects
testData<-cbind(subjecttest,ytest,xtest)

#Merge the training and the testing data sets (rbind) to create one data set
MergedData<-rbind(trainData,testData)

#Appropriately labels the data set with descriptive variable names
colnames(MergedData)<-c("subject","activty",DesiredFeatures.names)

#Convert activities & subjects into factors from activityLabels
MergedData$activity<-factor(MergedData$activty,levels=activity_labels[,1],labels=activity_labels[,2])
MergedData$subject<-as.factor(MergedData$subject)

#Appropriately labels the data set with descriptive variable names
names(MergedData)<-gsub("std()","SD",names(MergedData))
names(MergedData)<-gsub("mean()","MEAN",names(MergedData))
names(MergedData)<-gsub("^t","time",names(MergedData))
names(MergedData)<-gsub("^f","frequency",names(MergedData))
names(MergedData)<-gsub("Acc","Accelerameter",names(MergedData))
names(MergedData)<-gsub("Gyro","Gyroscope",names(MergedData))
names(MergedData)<-gsub("Mag","Magnitude",names(MergedData))
names(MergedData)<-gsub("BodyBody","Body",names(MergedData))

#Convert MergedData into a molten data frame
install.packages("reshape2")

library(reshape2)

MergedData.melted<-melt(MergedData, id=c("subject","activity"))

#Cast a molten data frame into data frame subject and activities are breaked by variables and averaged Basically, this creates a independent tidy data set with the average of each variable for each activity and each subject.
MergedData.mean<-dcast(MergedData.melted,subject+activity~variable, mean)

#Upload complete data set as a txt file created with write.table() using row.name=FALSE
write.table(MergedData.mean,file="TidyDataSet.txt",row.names=FALSE, quote= FALSE)
