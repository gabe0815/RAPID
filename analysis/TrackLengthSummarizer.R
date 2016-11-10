# track length summarizer and plotter for RAPID data
# 2016 Institut fuer Pathologie, USB, Basel
# J. Hench and G. Schweighauser
#-------------------------------------------------------------------

# tested and developed with:
#  R version 3.0.2 (2013-09-25) -- "Frisbee Sailing"
#  Platform: x86_64-pc-linux-gnu (64-bit)

library(survminer)
library(survival)
library(stringr)

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
                                afterLength = numeric(0),
                                  afterArea = numeric(0),
                                  afterEdge = numeric(0),
                              afterContours = numeric(0), 
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
    after <- c(NA, NA, NA, NA) # length, area, edge, contours
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
        before <- as.numeric(unlist(unname(rawTrackLength[beforeIdx,2:5]))) # length, area, edge, contours
        after <- as.numeric(unlist(unname(rawTrackLength[afterIdx,2:5])))          
				
			} else if (inputFiles[f] == "sampleID.txt"){ #required files for analysis
        rawSampleID <- readLines(filePath)
        sampleID <- rawSampleID[1]
        birthTimestamp <- as.numeric(rawSampleID[2])
				
			} else if (inputFiles[f] == "timestamp.txt"){ #required files for analysis
				currentTimestamp <- as.numeric(readLines(filePath))
				
			} else if (inputFiles[f] == "censored.txt"){ 
			  censoringParameters<-read.delim(filePath, header=FALSE, row.names=1) 
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
            cat("got empty file, skipping...","\n")
          } else {
            temperatureAssay <- as.numeric(rawTemperature[1,1])
            temperatureTable <- as.numeric(rawTemperature[1,2])
          }      
      }
		}
		
    if (any(is.na(sampleID), is.na(birthTimestamp), is.na(currentTimestamp), is.na(before), is.na(after)) == FALSE) {
      # append all parameter from each measurement in one huge data frame
      trackDataStrings <- c(sampleID, birthTimestamp, currentTimestamp, trackVersion, before, after, trackCensoredBefore, trackCensoredAfter, cameraSerial, cameraVersion, device, temperatureAssay, temperatureTable)

      trackDataCollector[nrow(trackDataCollector)+1,] <- trackDataStrings

    }

		setTxtProgressBar(progressBar,d)
   
  }
	cat(" done.\n")
	save(trackDataCollector, file=paste0(ResultOutputPath,"trackDataCollector_test.rda"))  
}


createPlots <- function(trackDataCollector,ResultOutputPath){  

  # figure out how many different groups we have
  includedStrains <- uniqueGroups(trackDataCollector)
  strainNumber <- length(includedStrains)

  # figure out which group has the most individuals
  numberOfWorms <- NULL
  for (i in includedStrains){
    numberOfWorms <- c(numberOfWorms, length(grep(i, unique(trackDataCollector$sampleID))))
  }
  numberPlotRows <- max(numberOfWorms)
  
  cat("\nnumber of strains: ", strainNumber, "\n", "max number of worms: ", numberPlotRows, "\n")
  # create an empty canvas with size unique groups x maximum number of individuals
 try(png(filename = paste0(ResultOutputPath,"Rplot001_",correctTrackVersionString,".png"), width = 400*strainNumber, height = 400*numberPlotRows, units = "px", pointsize = 14, bg  = "white"))
 try(par(mfrow=c(numberPlotRows, strainNumber))) # from http://www.statmethods.net/advgraphs/layout.html
  
  # go through the unique groups
  for (x in 1:length(includedStrains)){
    wormsPerStrain <- trackDataCollector[grep(includedStrains[x], trackDataCollector$sampleID), ]
    for (y in 1:length(unique(wormsPerStrain$sampleID))){
      singleWorm <- wormsPerStrain[which(wormsPerStrain$sampleID == wormsPerStrain$sampleID[y]), ]
      
      # do the plot at x,y on canvas

    par(mfg=c(y, x)) # define plotting location on muliple plot sheet http://stackoverflow.com/questions/4785657/r-how-to-draw-an-empty-plot
    try(plot(approx(singleWorm$days, singleWorm$afterArea, xout=seq(0,25,1/24)), main = wormsPerStrain$sampleID[y], xlab="time [days]", ylab="track length [px]", pch='.', type="l", ylim = c(0, 40000))) # plotting limits!

     } 
   }
   cat("writing plots to file ...")
   dev.off()
   cat(" done.\n")

}

plotMeanStDev <- function(trackDataCollector, ResultOutputPath){
#  summary <- data.frame(strain = character(0),
#                     timepoint = numeric(0),
#                 afterAreaMean = numeric(0),
#               afterAreaStdDev = numeric(0),
#                beforeAreaMean = numeric(0),
#              beforeAreaStdDev = numeric(0)
#                      )

  # figure out how many different groups we have
  includedStrains <- uniqueGroups(trackDataCollector)
  strainNumber <- length(includedStrains)

  # create an empty canvas with size 4 x number of groups / 4
  numberOfPlotsPerRow <- 4
  numberOfRows <- ceiling(strainNumber / numberOfPlotsPerRow)  
  
  png(filename = paste0(ResultOutputPath,"MEANplot001_",correctTrackVersionString,".png"), width = 400*numberOfPlotsPerRow, height = 400*numberOfRows, units = "px", pointsize = 14, bg = "white")
  par(mfrow=c(numberOfRows,numberOfPlotsPerRow))
  # go through the unique groups
  for (s in 1:length(includedStrains)){
    perStrainBeforeArea <- data.frame(c(rep(NA, 577)))
    perStrainAfterArea <- data.frame(c(rep(NA, 577)))
     
    wormsPerStrain <- trackDataCollector[grep(includedStrains[s], trackDataCollector$sampleID), ]
    i <- s%%numberOfPlotsPerRow
    if (i == 0){
      i <- numberOfPlotsPerRow
    }
    j <- ceiling(s/numberOfPlotsPerRow) 
    
    # create interpolated data sets for each worm
    for (w in length(unique(wormsPerStrain$sampleID))){
      thisWorm <- wormsPerStrain[which(wormsPerStrain$sampleID == wormsPerStrain$sampleID[w]),]
      perStrainBeforeArea <- cbind(perStrainBeforeArea, data.frame(approx(thisWorm$days, thisWorm$beforeArea, xout = seq(1,25,1/24))$y)) # y is the second column of the approx function
      perStrainAfterArea <- cbind(perStrainAfterArea, data.frame(approx(thisWorm$days, thisWorm$afterArea, xout = seq(1,25,1/24))$y))      
    }
    
    # calculate row-wise mean and stdDev and append this to the summary
    thisStrainMeanBefore <- apply(perStrainBeforeArea, 1, mean)
    thisStrainStdDevBefore <- apply(perStrainBeforeArea, 1, sd)
    thisStrainMeanAfter <- apply(perStrainAfterArea, 1, mean)
    thisStrainStdDevAfter <- apply(perStrainAfterArea, 1, sd)
    par(mfg=c(j, i))
    try(plot(seq(1,25, 1/24), thisStrainMeanAfter, main = includedStrains[s], xlab="time [days]", ylab="track length [px]", pch='.', type="l", ylim = c(0, 40000))) # plotting limits!

    save(thisWorm, file="/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/thisStrain.rda")
  }
  cat("writing plots to file ...")
  dev.off()
  cat(" done.\n")
}

censorData <- function(trackDataCollector,censoringList){
  # remove complete sets
	cat("\ncensoring data...\n")
	censNames <- readLines(censoringList)
  trackDataCollectorCensored <- trackDataCollector[!trackDataCollector$sampleID %in% censNames, ]

  # convert censored timepoints to NAs
  censorBefore <- c(which(trackDataCollectorCensored$beforeEdge == "1"), 
                    which(trackDataCollectorCensored$trackCensoredBefore == "1"), 
                    which(trackDataCollectorCensored$beforeArea == "-1")
                   )
  
  trackDataCollectorCensored$beforeArea[censorBefore] <- NA
  
  censorAfter <- c(which(trackDataCollectorCensored$afterEdge == "1"), 
                   which(trackDataCollectorCensored$trackCensoredAfter == "1"), 
                   which(trackDataCollectorCensored$afterArea == "-1")
                  )
  
  trackDataCollectorCensored$afterArea[censorAfter] <- NA
	
  # calculate worm age in days
  trackDataCollectorCensored$days <- ((as.numeric(trackDataCollectorCensored$currentTimestamp) - as.numeric(trackDataCollectorCensored$birthTimestamp))/(3600 * 24))
  
  cat(" done.\n")
	return(trackDataCollectorCensored)	
}

uniqueGroups <- function(trackDataCollector){
	
	sampleIDs <- unique(unlist(data.frame(str_split_fixed(trackDataCollector$sampleID, "_",2), stringsAsFactors=FALSE)[1]))

  cat("found the following samples: \n")
  cat(sampleIDs)
	return(sampleIDs)
}


lappend <- function (lst, addVar){ # adapted from http://stackoverflow.com/questions/9031819/add-named-vector-to-a-list/12978667#12978667
	lst <- c(lst, list(addVar))
		return(lst)
}

mat.sort <- function(mat,n) # from http://www.r-bloggers.com/sorting-a-matrixdata-frame-on-a-column/
{
	mat[rank(mat[,n]),] <- mat
	return(mat)
}

plotSurvival <- function(sortedFilteredCensoredRapidData) {
  # At the moment, the column to be checked is hardcoded (X7). This could be avoided if we proberly name columns.
  # All worms are collected in the same data frame. By having a group ID, they can be assigned during plotting.
  lastTimeAlive.df <- data.frame(ID = character(0), group = character(0), idx = numeric(0), stop = numeric(0), status = numeric(0))  
  for (i in 1:length(sortedFilteredCensoredRapidData)){
    lastTimeAliveIndex <- -1
    for (j in length(sortedFilteredCensoredRapidData[[i]]$X7):1){
       # there need to be two tracks within 3 time points for it to count
       if (sortedFilteredCensoredRapidData[[i]]$X7[j] > 0){
         if (lastTimeAliveIndex == -1){
           lastTimeAliveIndex <- j
          # we found a second track within 3 timepoints, add to df and exit the inner loop
         } else if ((lastTimeAliveIndex - j) <= 3){
     
           lastTimeAlive.df <- rbind(lastTimeAlive.df, data.frame(ID = as.character(sortedFilteredCensoredRapidData[[i]]$X1[lastTimeAliveIndex]), 
                                                               group = unlist(strsplit(as.character(sortedFilteredCensoredRapidData[[i]]$X1[lastTimeAliveIndex]), "_"))[1], 
                                                                 idx = as.numeric(unlist(strsplit(as.character(sortedFilteredCensoredRapidData[[i]]$X1[lastTimeAliveIndex]), "_"))[2]),
                                                                stop = sortedFilteredCensoredRapidData[[i]]$X8[lastTimeAliveIndex], 
                                                              status = 1))
           break
         } else { 
            lastTimeAliveIndex <- j
         }
       } 
    }
  } 
  
  #filter for certains groups (optional)
  load("/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/lastTimeAliveFrame.rda")
  #lastTimeAlive.df <- lastTimeAlive.df[grep("N2", lastTimeAlive.df$group), ]
  
  fit<- survfit(Surv(stop, status) ~ group, data = lastTimeAlive.df)
  ggsurvplot(fit, 
          legend = c("right"), 
    legend.title = "Strains", 
     #legend.labs = c("N2", "CB120", "CB246", "CB306", "CL2355", "LS292", "TJ1052", "ZZ17", "MT2426", "CB1072"),
     #legend.labs = c("N2, 10 µM FUdR", "N2, 20 µM FUdR", "N2, 40 µM FUdR"),
     #legend.labs = c("SS104, 10 µM FUdR", "SS104, 0 µM FUdR", "N2, 10 µM FUdR (old)", "N2, 10 µM FUdR"), 
            main = "Lifespan",
            xlab = "Days",
            ylab = "Fraction surving",
            xlim = c(0,30),
   break.time.by = 5,
      risk.table = TRUE
   
 
            )
  # add more ticks           

  # need to find the right parameters to make it look nice
  ggsave("/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/survival.png") 
  save(lastTimeAlive.df, file="/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/lastTimeAliveFrame.rda")

}



# global parameters (use <<- instead of <-)
columToAnalyze <<- 7 # after track area
#columToAnalyze <<- 5 # before track area
correctTrackVersionString <<- "trackVersion.v13"

# enter RAPID source and output directories here
# usage
  #summarizeTracks("/RAPID/input/dir","/result/output/dir")

#summarizeTracks("/mnt/4TBraid04/imagesets04/20151203_vibassay_set2","/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20151203_vibassay_set2/")
#summarizeTracks("/mnt/4TBraid04/imagesets04/20160122_vibassay_set3","/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160122_vibassay_set3/")
#summarizeTracks("/mnt/4TBraid04/imagesets04/20160217_vibassay_set4","/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160217_vibassay_set4/")
#summarizeTracks("/mnt/4TBraid04/imagesets04/20160311_vibassay_set5","/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160311_vibassay_set5/")
#summarizeTracks("/mnt/4TBraid04/imagesets04/20160406_vibassay_set6","/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160406_vibassay_set6/")
#summarizeTracks("/mnt/4TBraid04/imagesets04/20160504_vibassay_set7","/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160504_vibassay_set7/")
#summarizeTracks("/mnt/4TBraid04/imagesets04/20160615_vibassay_set8","/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160615_vibassay_set8/")
#summarizeTracks("/mnt/4TBraid04/imagesets04/20160720_vibassay_set9","/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160720_vibassay_set9/")
#summarizeTracks("/mnt/4TBraid04/imagesets04/20160217_vibassay_set4","/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/")
#summarizeTracks("/mnt/4TBraid04/imagesets04/20160810_vibassay_set10_censored","/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160810_vibassay_set10/")
#summarizeTracks("/mnt/4TBraid04/imagesets04/20160902_vibassay_set11","/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160902_vibassay_set11/")
#summarizeTracks("/mnt/4TBraid04/imagesets04/20160919_vibassay_set12","/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160919_vibassay_set12/")
#summarizeTracks("/mnt/4TBraid04/imagesets04/SS104_set2_analysisV13","/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_SS104_set2_analysisV13/")


print("summarize_done")

#stop()

#load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20151203_vibassay_set2/trackDataCollector.rda")
# tracks2 <- trackDataCollector
 #load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160122_vibassay_set3/trackDataCollector.rda")
# tracks3 <- trackDataCollector
#load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160217_vibassay_set4/trackDataCollector.rda")
# tracks4 <- trackDataCollector
# load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160311_vibassay_set5/trackDataCollector.rda")
# tracks5 <- trackDataCollector
# #stop()
#load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160406_vibassay_set6/trackDataCollector.rda")
# tracks6 <- trackDataCollector
#load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160504_vibassay_set7/trackDataCollector.rda")
# tracks7 <- trackDataCollector
#load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160615_vibassay_set8/trackDataCollector.rda")
# tracks8 <- trackDataCollector
# load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160720_vibassay_set9/trackDataCollector.rda")
# tracks9 <- trackDataCollector
#load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160810_vibassay_set10/trackDataCollector.rda")
#tracks10 <- trackDataCollector
#load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160902_vibassay_set11/trackDataCollector.rda")
#tracks11 <- trackDataCollector
#load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160919_vibassay_set12/trackDataCollector.rda")
#tracks12 <- trackDataCollector
#trackDataCollector<-c(tracks2,tracks3,tracks4,tracks5,tracks6,tracks7,tracks8,tracks9)
#trackDataCollector<-tracks10
#load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_SS104_set2_analysisV13/trackDataCollector.rda")
#tracks2 <- trackDataCollector
#trackDataCollector<-c(tracks10,tracks11,tracks12)

load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160919_vibassay_set12/trackDataCollector_test.rda")
trackDataCollectorCensored <- censorData(trackDataCollector,"/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/censoringList.txt")
uniqueGroups(trackDataCollectorCensored)
#createPlots(trackDataCollectorCensored, "/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/")
plotMeanStDev(trackDataCollectorCensored, "/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/")
#save(trackDataCollectorCensored, file = "/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160919_vibassay_set12/trackDataCollector_censored.rda")

#trackDataCollector<-censorData(trackDataCollector,"/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/censoringList.txt")


      #print(trackDataCollector[[length(trackDataCollector)]])
      #print(typeof(trackDataCollector))
      #print(length(trackDataCollector))
      #print("------------------------")
      #load("trackDataCollector.rda")
      #createMeanPlots(trackDataCollector,"/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/")
#createPlots(trackDataCollector,"/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/")

# next 3 lines WORK!
#load("/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/censoredUnzeroedRapidData.rda")
#load("/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/sortedFilteredCensoredRapidData.rda")
#plotSurvival(sortedFilteredCensoredRapidData)


#groupwiseDataCollector_statData<-createMeanPlots(censoredUnzeroedRapidData,"/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/")

#save(groupwiseDataCollector_statData, file="/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/groupwiseDataCollector_statData.rda")
#load("/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/groupwiseDataCollector_statData.rda")

#plotAnova(groupwiseDataCollector_statData)
#plotMeanStDev(groupwiseDataCollector_statData)
