

# This script processes the UCI HAR study data found here
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# it presumes the zip file has been extracted to the working directory
# and no other change has been made to the file structure or files

processuciHARstudy <- function(download=FALSE){
  
      # check that required packages are loaded
      # needs stringr, readr, dplyr, reshape2
      require(stringr)
      require(readr)
      require(dplyr)
      require(reshape2)
  
      # checks if download is necessary (default behavior)
      # otherwise presumes the working directory contains
      # the required data structure per README.md
      curwd <- getwd()
  
    if(download){
                  if(!file.exists("ucidata")){dir.create("ucidata")}

                  setwd("./ucidata")
                  
                  # attempt to retrieve and extract data
                  uciurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
                  download.file(uciurl,destfile = "uci.zip")
                  unzip("./uci.zip")
                  
    }
  
    # variables for required files
    basePath <- "./UCI HAR Dataset/"
    testPath <- "./UCI HAR Dataset/test/"
    trainPath <- "./UCI HAR Dataset/train/"
    featuresPath <- str_c(basePath,"features.txt")
    activitiesLabelsPath <- str_c(basePath, "activity_labels.txt")
    subjectTestPath <- str_c(testPath,"subject_test.txt")
    obsTestPath <- str_c(testPath, "X_test.txt")
    activitiesTestPath <- str_c(testPath,"y_test.txt")
    subjectTrainPath <- str_c(trainPath,"subject_train.txt")
    obsTrainPath <- str_c(trainPath, "X_train.txt")
    activitiesTrainPath <- str_c(trainPath,"y_train.txt")
    widths <- rep.int(16,561)
    
    
    
    # ingest feature and activity label files
    featuresRaw <- read_delim(featuresPath," ",
                               col_names = c("featureid","featurerawname"))
    activitiesLabelsRaw <- read_delim(activitiesLabelsPath," "
                                      ,col_names = c("activityid","activityrawname"))

    # ingest and merge training data
    subjectTrain <- read_delim(subjectTrainPath," "
                               ,col_names = c("subjectid"))
    activitiesTrain <- read_delim(activitiesTrainPath," "
                                  ,col_names = c("activityid"))
    
    obsTrain <- read_fwf(obsTrainPath,fwf_widths(widths
                                    ,col_names = featuresRaw$featurerawname))
    #limit to fields of interest
    z <- grep("mean\\(\\)|std\\(\\)",names(obsTrain))
    obsTrain <- obsTrain[,z]
    obsTrain$activityid <- activitiesTrain$activityid
    obsTrain$subjectid <- subjectTrain$subjectid
    
    # ingest and merge test data
    subjectTest <- read_delim(subjectTestPath," "
                              ,col_names = c("subjectid"))
    activitiesTest <- read_delim(activitiesTestPath," "
                                 ,col_names = c("activityid"))
    
    obsTest <- read_fwf(obsTestPath,fwf_widths(widths
                                               ,col_names = featuresRaw$featurerawname))
    #limit to fields of interest
    z <- grep("mean\\(\\)|std\\(\\)",names(obsTest))
    obsTest <- obsTest[,z]
    
    obsTest$activityid <- activitiesTest$activityid
    obsTest$subjectid <- subjectTest$subjectid 
    
    # clean activity names
    activities <- tolower(gsub("_","",activitiesLabelsRaw$activityrawname))
    activitiesLabelsRaw$activityname <- activities
    activitiesLabels <- select(activitiesLabelsRaw,activityid,activityname)

    # merge the training and test data
    obsAll <- rbind_list(obsTrain,obsTest)
    
    # add the clean activity labels and remove activityid
    obsAll <- inner_join(obsAll,activitiesLabels, by = "activityid")
    obsAll <- select(obsAll,-activityid)
    obsAll <- obsAll[,c(67,68,1:(ncol(obsAll)-2))]
    
    # clean feature names for tidy data set
    names(obsAll) <- gsub("-mean\\(\\)[-]?","Mean",names(obsAll))
    names(obsAll) <- gsub("-std\\(\\)[-]?","Stddev",names(obsAll))
    

    # create tidy data set, mean all variables for each activity and subject
    varName <- names(select(obsAll, -(subjectid:activityname)))
    
    obsAllMelt <- melt(obsAll,id=c("subjectid","activityname")
                       ,measure.vars = varName)
    
    tidy <- dcast(obsAllMelt, subjectid + activityname ~ variable, mean)
    
    #reset to original working directory
    setwd(curwd)
    
    # return the tidy data to user
    tidy 
  
    
}
