---
title: "UCI HAR Dataset Process"
author: "Tom Gamon"
date: "April 3, 2016"
---

###Summary

The run_analysis.R script contains one function named processuciHARstudy(download=FALSE). When the parameter is set to TRUE the function will attempt to download the file from the provided source
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip. 
The default behavior for the function is to presume there is a directory "./UCI HAR Dataset/" in the working directory.

###Packages Required

The script was created using R version 3.2.3 "Wooden Christmas-Tree" and requires the following packages:

- stringr
- readr
- dplyr
- reshape2

###Behavior
The script processes 8 text files in the provided UCI HAR dataset by adding subject and activity data to the observation data for both the train and test subjects. It then selects the desired mean and standard deviation measurements from both datasets and merges them a single dataset. The processed activity names are joined with the single dataset 

Non-alphanumeric characters are removed from the variables to improve readability. Since the full description of the variables would be very lengthy they are left in abbreviated form. Their full descriptions are available in the code book.

The unified dataset is then melted using the "subjectid" and "activityname" as id's. Next the melted data set is reformed by taking the mean of the variables with respect to the aforementioned id's.

Finally the tidy data set is returned to the user.

###Steps
1. Download the zip file from the [UCI HAR Study](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
2. Extract the file to your R sessions working directory
3. Source the run_analysis.R script
4. Verify that the required R packages are installed
5. Assign the output from function processuciHARstudy() to a variable

Note: Steps 1-2 can be skipped if set the function parameter to TRUE i.e. processuciHARstudy(download=TRUE). The script will attempt to download the study and then process.
