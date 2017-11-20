# track length summarizer and plotter for RAPID data
# 2016 Institut fuer Pathologie, USB, Basel
# J. Hench and G. Schweighauser
#-------------------------------------------------------------------

# tested and developed with:
#  R version 3.0.2 (2013-09-25) -- "Frisbee Sailing"
#  Platform: x86_64-pc-linux-gnu (64-bit)

# usage: 
#summarizeTracks("/RAPID/input/dir","/result/output/dir")
#TDC_censored <- censorData(TDC, censoringList = "/path/to/file")

library(survminer)
library(survival)
library(stringr)
library(tibble)
library(multcomp)

summarizeTracks <- function(RapidInputPath,ResultOutputPath){
	print(RapidInputPath)
	print(ResultOutputPath)
	cat("loading directory structure to RAM...")
	trackDataCollector <- data.frame(sampleID = character(0), 
                             birthTimestamp = numeric(0),
                           currentTimestamp = numeric(0),
                               trackVersion = numeric(0),
                               beforeLength = numeric(0),
                                 beforeArea = numeric(0),
                                 beforeEdge = numeric(0),
                             beforeContours = numeric(0),
                            beforeMeanSpeed = numeric(0),
                         beforeMeasurements = numeric(0),
                                afterLength = numeric(0),
                                  afterArea = numeric(0),
                                  afterEdge = numeric(0),
                              afterContours = numeric(0),
                             afterMeanSpeed = numeric(0),
                          afterMeasurements = numeric(0), 
                        trackCensoredBefore = numeric(0),
                         trackCensoredAfter = numeric(0),
                               cameraSerial = character(0),
                              cameraVersion = numeric(0),
                                     device = numeric(0),
                           temperatureAssay = numeric(0),
                           temperatureTable = numeric(0), 
                           stringsAsFactors = FALSE

                     ) # initialize the data frame with proper column names
	rapidDirectories <- list.dirs(RapidInputPath, recursive=FALSE)
	cat(" done.\n")
	cat("collecting data from RAPID datasets:\n")
	cat("|0%.......................100%|\n")
	progressBar <- txtProgressBar(min = 1, max = length(rapidDirectories), initial = 1, char = "=",width = 30, title, label, style = 1, file = "")
	for (d in 1:length(rapidDirectories)){
		pathDirs <- strsplit(rapidDirectories[d], "/", fixed = FALSE, perl = FALSE, useBytes = FALSE)	
		datapointDir <- pathDirs[[1]][length(pathDirs[[1]])] # it's a list!
		
    if (substring(datapointDir,1,2) != "dl"){ # prefix for datapoint directories	
      next
    }
		inputFiles <- list.files(path = rapidDirectories[d], pattern = NULL, all.files = FALSE, full.names = FALSE, recursive = FALSE, ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)

    sampleID <- NA
    birthTimestamp <- NA
    currentTimestamp <- NA
    trackVersion <- NA
    before <- c(NA, NA, NA, NA) # length, area, edge, contours
    after <- c(NA, NA, NA, NA)
    beforeSpeed <- c(NA, NA) # mean speed, measurements
    afterSpeed <- c(NA, NA)
    trackCensoredBefore <- NA
    trackCensoredAfter <- NA 
    cameraSerial <- NA
    cameraVersion <- NA
    device <- NA
    temperatureAssay <- NA
    temperatureTable <- NA

    # read all files and parse their content
	if (length(inputFiles)<2){
      next # skip to the next item in the for loop
    } 

	for (f in 1:length(inputFiles)){
			filePath <- paste0(rapidDirectories[d],"/",inputFiles[f], collapse = NULL)
      #cat("reading from: ", filePath, "\n")

        if (inputFiles[f] == "trackLength.tsv"){ #required files for analysis
             rawTrackLength <- read.delim(filePath,header = TRUE, sep = "\t")
               trackVersion <- names(rawTrackLength)[1]
                  beforeIdx <- which(rawTrackLength[,1] == "before")
                   afterIdx <- which(rawTrackLength[,1] == "after")
                      # length, area, edge, contours
                     before <- as.numeric(unlist(unname(rawTrackLength[beforeIdx,2:5])))
                      after <- as.numeric(unlist(unname(rawTrackLength[afterIdx,2:5])))

        } else if (inputFiles[f] == "meanSpeed.csv"){          
				    rawMeanSpeeds <- read.csv(filePath, header = T)
            beforeSpeed <- as.numeric(rawMeanSpeeds[which(rawMeanSpeeds$stimulus == "before"), 2-3])
            afterSpeed <- as.numeric(rawMeanSpeeds[which(rawMeanSpeeds$stimulus == "after"), 2-3])
          

        } else if (inputFiles[f] == "sampleID.txt"){ #required files for analysis
                rawSampleID <- readLines(filePath)
                   sampleID <- rawSampleID[1]
             birthTimestamp <- as.numeric(rawSampleID[2])
				
        } else if (inputFiles[f] == "timestamp.txt"){ #required files for analysis
            currentTimestamp <- as.numeric(readLines(filePath))
				
        } else if (inputFiles[f] == "censored.txt"){ 
            censoringParameters <- read.delim(filePath, header=FALSE, row.names=1) 
            trackCensoredBefore <- censoringParameters["before",]
             trackCensoredAfter <- censoringParameters["after",]

        } else if (inputFiles[f] == "camera.txt"){
               rawCamera <- readLines(filePath)
            cameraSerial <- rawCamera[1]
                  device <- rawCamera[2]

        } else if (inputFiles[f] == "version.txt"){
            cameraVersion <- readLines(filePath)

        } else if (inputFiles[f] == "temperature.txt"){
            rawTemperature <- try(read.csv(filePath, header = FALSE, sep = ",", stringsAsFactors = FALSE))
            if(inherits(rawTemperature, "try-error")) {
                #cat("got empty file, skipping...","\n")
            } else {
                temperatureAssay <- as.numeric(rawTemperature[1,1])
                temperatureTable <- as.numeric(rawTemperature[1,2])
            }      
        }
    }
		
    if (any(is.na(sampleID), is.na(birthTimestamp), is.na(currentTimestamp), is.na(before), is.na(after)) == FALSE) {
      # append all parameter from each measurement in one huge data frame
        trackDataStrings <- c(
                              sampleID, 
                        birthTimestamp, 
                      currentTimestamp, 
                          trackVersion, 
                                before, 
                           beforeSpeed, 
                                 after, 
                            afterSpeed, 
                   trackCensoredBefore, 
                    trackCensoredAfter, 
                          cameraSerial, 
                         cameraVersion, 
                                device, 
                      temperatureAssay, 
                      temperatureTable
                            )
        
        # check if we got all parameters before appending:
        if (length(trackDataStrings) != ncol(trackDataCollector)){
            cat("missing parameters, skipping ...", "\n")
            #cat(trackDataStrings, "\n")
        } else {
            trackDataCollector[nrow(trackDataCollector)+1,] <- trackDataStrings
        }

    }

		setTxtProgressBar(progressBar,d)
   
  }
  # remove entries with wrong trackVersion string
  trackDataCollector <- trackDataCollector[which(trackDataCollector$trackVersion == correctTrackVersionString), ]
	
  # add a column for the set
  trackDataCollector$setID <- unlist(str_split(RapidInputPath, "_set"))[2]
  
  cat(" done.\n")
	save(trackDataCollector, file=paste0(ResultOutputPath, "trackDataCollector_V", TrackLengthSummarizerVersion, ".rda"))  
}

censorData <- function(trackDataCollector, censoringList){
  # remove complete sets
	cat("\ncensoring data...\n")
	censNames <- readLines(censoringList)
  trackDataCollectorCensored <- trackDataCollector[!trackDataCollector$sampleID %in% censNames, ]
  
  # convert chars to numeric
cols.num <- c("birthTimestamp", 
              "currentTimestamp", 
              "beforeLength", 
              "beforeArea", 
              "beforeEdge", 
              "beforeContours", 
              "beforeMeanSpeed", 
              "beforeMeasurements", 
              "afterLength", 
              "afterArea", 
              "afterEdge", 
              "afterContours", 
              "afterMeanSpeed", 
              "afterMeasurements", 
              "trackCensoredBefore", 
              "trackCensoredAfter", 
              "temperatureAssay", 
              "temperatureTable", 
              "setID")

  trackDataCollectorCensored[cols.num] <- sapply(trackDataCollectorCensored[cols.num],as.numeric)

  # convert censored timepoints to NAs
  censorBefore <- c(which(trackDataCollectorCensored$beforeEdge == 1), 
                    which(trackDataCollectorCensored$trackCensoredBefore == 1), 
                    which(trackDataCollectorCensored$beforeArea == -1),
                    which(trackDataCollectorCensored$beforeArea == 0)
                   )
  
  trackDataCollectorCensored$beforeArea[censorBefore] <- NA
  
  censorAfter <- c(which(trackDataCollectorCensored$afterEdge == 1), 
                   which(trackDataCollectorCensored$trackCensoredAfter == 1), 
                   which(trackDataCollectorCensored$afterArea == -1),
                   which(trackDataCollectorCensored$afterArea == 0)
                  )

  trackDataCollectorCensored$afterArea[censorAfter] <- NA

  censorTemperatureAssay <- c(which(trackDataCollectorCensored$temperatureAssay == -1))
  trackDataCollectorCensored$temperatureAssay[censorTemperatureAssay] <- NA
	
  censorTemperatureTable <- c(which(trackDataCollectorCensored$temperatureTable == -1))
  trackDataCollectorCensored$temperatureTable[censorTemperatureTable] <- NA

  # calculate worm age in days
  trackDataCollectorCensored$days <- ((as.numeric(trackDataCollectorCensored$currentTimestamp) - as.numeric(trackDataCollectorCensored$birthTimestamp))/(3600 * 24))
  
  # add groupID
  trackDataCollectorCensored$groupID <- str_split_fixed(trackDataCollectorCensored$sampleID, "_",2)[,1]
  cat(" done.\n")
  return(trackDataCollectorCensored)	
}

# global parameters (use <<- instead of <-)
correctTrackVersionString <<- "trackVersion.v13"
TrackLengthSummarizerVersion <<- 3
