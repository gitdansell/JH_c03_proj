

library(readr)
setwd(paste(getwd(),'/../JH_c03_proj_data/'))
print(getwd())

# 1. Merges the training and the test sets to create one data set.
xtest = read.table('test/X_test.txt')
xtrain = read.table('train/X_train.txt')
xall = rbind(xtest, xtrain)

ytest = read.table('test/y_test.txt')
ytrain = read.table('train/y_train.txt')
yall = rbind(ytest, ytrain)

subjecttest = read.table('test/subject_test.txt')
subjecttrain = read.table('train/subject_train.txt')
subjectall = rbind(subjecttest, subjecttrain)

# 2. Extracts only the measurements on the mean and standard deviation for each record. 
features_all = read.table('features.txt')
features_mean_std_index = grep('mean|std', features_all[,2])
xall_lean = xall[, features_mean_std_index]

# 3. Uses descriptive activity names to name the activities in the data set
library(dplyr)
activity_labels = read.table('activity_labels.txt')
colnames(activity_labels) = c('id', 'Activity')
colnames(yall) = c('activity_id')
yall_activity = inner_join(yall, activity_labels, join_by(activity_id == id))

# 4. Appropriately labels the data set with descriptive variable names. 
colnames(xall_lean) = features_all[features_mean_std_index, 2]

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(dcast)

#assign col name to subjectall so that it can be used in a join:
colnames(subjectall) = 'subject'

        #combine the x, y, and subject data:
tidy = cbind(subjectall, yall_activity, xall_lean) %>%
        #remove the activity_id col
       select(-activity_id) %>%
        #aggregate on subject & Activity:
       reshape2::melt(id.vars=c('subject', 'Activity'))  %>%
       reshape2::dcast(subject + Activity ~ ..., mean)

# Export the tidy dataset to file.
write.csv(tidy, "tidy_data.csv")
