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
library(tibble)

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
  # remove entries with wrong trackVersion string
  trackDataCollector <- trackDataCollector[which(trackDataCollector$trackVersion == correctTrackVersionString), ]
	
  # add a column for the set
  trackDataCollector$setID <- unlist(str_split(RapidInputPath, "_set"))[2]
  
  cat(" done.\n")
	save(trackDataCollector, file=paste0(ResultOutputPath, "trackDataCollector_V", TrackLengthSummarizerVersion, ".rda"))  
}

loadTracks <- function(RapidInputPath){
  trackDataCollectorAllSets <- NULL
  files <- list.files(RapidInputPath, pattern = paste0("_V", TrackLengthSummarizerVersion, ".rda"), recursive = TRUE)
  
  for (f in files){
    trackDataCollector <- NULL # clear the previous trackDataCollector to avoid loading it twice
    cat("\nloading trackDataCollector: ", paste0(RapidInputPath, f))
    load(paste0(RapidInputPath, f))
#    print(head(trackDataCollector))
    trackDataCollectorAllSets <- rbind(trackDataCollectorAllSets, trackDataCollector)
  }
 
  return (trackDataCollectorAllSets)

  
}

createPlots <- function(trackDataCollector, ResultOutputPath){  

  # figure out how many different groups we have
  strains <- unique(trackDataCollector$groupID)
  numberOfStrains <- length(strains)

  # figure out which group has the most individuals
  numberOfWorms <- NULL
  for (i in strains){
    numberOfWorms <- c(numberOfWorms, length(grep(i, unique(trackDataCollector$sampleID))))
  }
  numberOfPlotsPerRow <- max(numberOfWorms)
  
  cat("\nnumber of strains: ", numberOfStrains, "\n", "max number of worms: ", numberOfPlotsPerRow, "\n")
  # create an empty canvas with size unique groups x maximum number of individuals

  svg(filename = paste0(ResultOutputPath, "Rplot001_", correctTrackVersionString,".svg"), 
       width = 7*numberOfStrains, 
      height = 7*numberOfPlotsPerRow,
   pointsize = 14,
          bg = "white")
  
  par(mfrow=c(numberOfPlotsPerRow, numberOfStrains)) # from http://www.statmethods.net/advgraphs/layout.html
  
  # go through the unique groups
  for (x in 1:length(strains)){
    wormsPerStrain <- trackDataCollector[grep(strains[x], trackDataCollector$sampleID), ]
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

plotMeanSD <- function(trackDataCollector, ResultOutputPath){

  # figure out how many different groups we have
  strains <- unique(trackDataCollector$groupID)
  numberOfStrains <- length(strains)

  # create an empty canvas with size 4 x number of groups / 4
  numberOfPlotsPerRow <- 4
  numberOfRows <- ceiling(numberOfStrains / numberOfPlotsPerRow)  
  
  svg(filename = paste0(ResultOutputPath, "MEANandSTDEVplot001_", correctTrackVersionString,".svg"), 
         width = 7*numberOfPlotsPerRow, 
        height = 7*numberOfRows,
     pointsize = 14,
            bg = "white")

  par(mfrow=c(numberOfRows,numberOfPlotsPerRow))
  # go through the unique groups
  for (s in 1:length(strains)){

#    perStrainBeforeArea <- data.frame(matrix(0, ncol = 0, nrow = length(seq(1,25, 1/24))))
    perStrainAfterArea <- data.frame(matrix(0, ncol = 0, nrow = length(seq(1,25, 1/24))))
    perStrainTemperatureTable <- data.frame(matrix(0, ncol = 0, nrow = length(seq(1,25, 1/24))))
    perStrainTemperatureAssay <- data.frame(matrix(0, ncol = 0, nrow = length(seq(1,25, 1/24))))

    wormsPerStrain <- trackDataCollector[grep(strains[s], trackDataCollector$sampleID), ]
    i <- s%%numberOfPlotsPerRow
    if (i == 0){
      i <- numberOfPlotsPerRow
    }
    j <- ceiling(s/numberOfPlotsPerRow) 
    
    # create interpolated data sets for each worm and append to strain based data frame
    for (w in 1:length(unique(wormsPerStrain$sampleID))){
      thisWorm <- wormsPerStrain[which(wormsPerStrain$sampleID == unique(wormsPerStrain$sampleID)[w]), ]

#      thisWormApproxBefore <- data.frame(approx(thisWorm$days, thisWorm$beforeArea, xout = seq(1,25,1/24))$y)
      thisWormApproxAfter <- data.frame(approx(thisWorm$days, thisWorm$afterArea, xout = seq(1,25,1/24))$y)
      thisWormTemperatureTable <- data.frame(approx(thisWorm$days, thisWorm$temperatureTable, xout= seq(1,25,1/24))$y)
      thisWormTemperatureAssay <- data.frame(approx(thisWorm$days, thisWorm$temperatureAssay, xout= seq(1,25,1/24))$y)
#      colnames(thisWormApproxBefore) <- unique(wormsPerStrain$sampleID)[w]
      colnames(thisWormApproxAfter) <- unique(wormsPerStrain$sampleID)[w]

#      perStrainBeforeArea <- cbind(perStrainBeforeArea, thisWormApproxBefore) # y is the second column of the approx function
      perStrainAfterArea <- cbind(perStrainAfterArea, thisWormApproxAfter)
      perStrainTemperatureTable <- cbind(perStrainTemperatureTable, thisWormTemperatureTable)
      perStrainTemperatureAssay <- cbind(perStrainTemperatureAssay, thisWormTemperatureAssay)
    }
   
    # calculate row-wise mean and stdDev and append this to the summary
#    thisStrainMeanBefore <- apply(perStrainBeforeArea, 1, mean)
#    thisStrainStdDevBefore <- apply(perStrainBeforeArea, 1, sd)
    thisStrainMeanAfter <- apply(perStrainAfterArea, 1, mean)
    thisStrainStdDevAfter <- apply(perStrainAfterArea, 1, sd)
    thisStrainMeanTemperatureTable <- apply(perStrainTemperatureTable, 1, mean)
    thisStrainMeanTemperatureAssay <- apply(perStrainTemperatureAssay, 1, mean)    
    
    par(mfg=c(j, i), mar=c(5,5,2,5), cex.lab=1.5) # margin: c(bottom, left, top, right)
    plot(seq(1,25, 1/24), thisStrainMeanAfter, main = strains[s], xlab="time [days]", ylab="track length [px]", pch='.', type="l", ylim = c(0, 40000)) # plotting limits!
    lines(seq(1,25, 1/24), thisStrainMeanAfter + thisStrainStdDevAfter,col="gray")
    lines(seq(1,25, 1/24), thisStrainMeanAfter - thisStrainStdDevAfter,col="gray")

    # plot temperature
    par(new = TRUE)
    plot(seq(1,25, 1/24), thisStrainMeanTemperatureAssay, axes=FALSE, type="l", col = "blue", ylim = c(0, 30), ann=FALSE)
    abline(h = mean(thisStrainMeanTemperatureAssay, na.rm = TRUE), col = "blue") 
    lines(seq(1,25, 1/24), thisStrainMeanTemperatureTable, col = "red", ann=FALSE)
    abline(h = mean(thisStrainMeanTemperatureTable, na.rm = TRUE), col = "red")
    axis(side = 4)
    mtext(side = 4, line = 3, 'Temperature [°C]')

    #save(perStrainAfterArea, file="/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/thisStrain.rda")
  }
  cat("writing plots to file ...")
  dev.off()
  cat(" done.\n")
}

plotAnova <- function(trackDataCollector, ResultOutputPath){
  
  # create an empty canvas with the right size 
  numberOfPlotsPerRow <- 4  
  numberOfPlots <- choose(length(unique(trackDataCollector$groupID)),2)
  numberOfRows <- ceiling(numberOfPlots / numberOfPlotsPerRow)
  # plot the anova p values

  svg(filename = paste0(ResultOutputPath, "ANOVAplot001_", correctTrackVersionString,".svg"), 
         width = 7*numberOfPlotsPerRow, 
        height = 7*numberOfRows,
     pointsize = 14,
            bg = "white")
  par(mfrow=c(numberOfRows,numberOfPlotsPerRow))


  # construct a data frame with approximate area values with After Area 
  approxAfterArea <- data.frame(matrix(0, ncol = 0, nrow = length(seq(1,25, 1/24))))
  sampleIDs <- NULL 

  for (w in unique(trackDataCollector$sampleID)){
      thisWorm <- trackDataCollector[which(trackDataCollector$sampleID == w), ]
      thisWormApproxAfter <- data.frame(approx(thisWorm$days, thisWorm$afterArea, xout = seq(1,25,1/24))$y)
      # add the approximated values as a column to the data frame, and append the groupID
      approxAfterArea <- cbind(approxAfterArea, thisWormApproxAfter)
      sampleIDs <- c(sampleIDs, thisWorm$sampleID[1])
  }
  
  cat("\nCalculate ANOVA p-values for all combinations\n")
  cat("|0%.......................100%|\n")
  progressBar <- txtProgressBar(min = 1, max = nrow(approxAfterArea), initial = 1, char = "=",width = 30, title, label, style = 1, file = "")

  colnames(approxAfterArea) <- sampleIDs
  anovaSummary <- data.frame(matrix(0, ncol = 0, nrow = numberOfPlots))
  firstAnova <- TRUE
  # loop through all time points 
  for (r in 1:nrow(approxAfterArea)){
    currentTime <- data.frame(t(approxAfterArea[r,]))
    colnames(currentTime) <- "afterArea"
    currentTime <- rownames_to_column(currentTime, var = "sampleID")
    currentTime$groupID <- str_split_fixed(currentTime$sampleID, "_",2)[,1]
    if (any(is.na(currentTime$afterArea))){
      anovaSummary <- cbind(anovaSummary, c(rep(NA, numberOfPlots)))
    } else {    
      currentTime.aov <- aov(afterArea ~ groupID, data = currentTime)
      currentAnova <-  data.frame(TukeyHSD(currentTime.aov)[1])
      anovaSummary <- cbind(anovaSummary, data.frame(currentAnova$groupID.p.adj))
      # extarct row names
      if (firstAnova == TRUE){
        rowNames <- rownames(currentAnova)
        firstAnova <- FALSE
      }
    }
  setTxtProgressBar(progressBar,r)
  }
  
  cat("\nplotting ANOVA p-values")
#  load("/home/gabe/OldAlbert/media/4TBexternal/sync/PhD/TrackLengthSummarizer/anovaSummary.rda")
  rownames(anovaSummary) <- rowNames
 
  for (r in 1:nrow(anovaSummary)){
    i <- r%%numberOfPlotsPerRow
    if (i == 0){
      i <- numberOfPlotsPerRow
    }
    j <- ceiling(r/numberOfPlotsPerRow) 
  
    par(mfg=c(j, i))
    plot(seq(1,25, 1/24), anovaSummary[r,],log="y", main = rowNames[r], xlab="time [days]", ylab="p-value [ANOVA]", pch='.', type="l", ylim=c(0.00000001,1))
    abline(h = 0.05, col = "red")     
  }
  
  cat("\nwriting plots to file ...")
  dev.off()
  cat("\ndone.\n")

 
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

  censorTemperatureAssay <- c(which(trackDataCollectorCensored$temperatureAssay == "-1"))
  trackDataCollectorCensored$temperatureAssay[censorTemperatureAssay] <- NA
	
  censorTemperatureTable <- c(which(trackDataCollectorCensored$temperatureTable == "-1"))
  trackDataCollectorCensored$temperatureTable[censorTemperatureTable] <- NA

  # calculate worm age in days
  trackDataCollectorCensored$days <- ((as.numeric(trackDataCollectorCensored$currentTimestamp) - as.numeric(trackDataCollectorCensored$birthTimestamp))/(3600 * 24))
  
  # add groupID
  trackDataCollectorCensored$groupID <- str_split_fixed(trackDataCollectorCensored$sampleID, "_",2)[,1]
    
  cat(" done.\n")
	return(trackDataCollectorCensored)	
}

plotSurvival <- function(trackDataCollector, ResultOutputPath) {
  
  # All worms are collected in the same data frame. By having a group ID, they can be assigned during plotting.
  lastTimeAlive <- trackDataCollector[0,]
  
  # get last time alive for each worm
  for (i in 1:length(unique(trackDataCollector$sampleID))){
    thisWorm <- trackDataCollector[which(trackDataCollector$sampleID == unique(trackDataCollector$sampleID)[i]), ]

    lastTimeAliveIndex <- -1
    
    for (j in length(thisWorm$afterArea):1){

      if ((is.na(thisWorm$afterArea[j]) == FALSE) && (thisWorm$afterArea[j] > 0)) {
        if (lastTimeAliveIndex == -1){
          lastTimeAliveIndex <- j
        } else if ((lastTimeAliveIndex - j) <= 3){
          lastTimeAlive[nrow(lastTimeAlive)+1, ] <- thisWorm[j, ]
          break         
        } else { 
          lastTimeAliveIndex <- j 
        }
      }     
    }
  
  } 
  
  # plotting
  lastTimeAlive$status <- 1

  fit<- survfit(Surv(days, status) ~ groupID, data = lastTimeAlive)
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
   break.time.by = 5 
            )
  # add more ticks           

  # need to find the right parameters to make it look nice
  ggsave(paste0(ResultOutputPath,"Surv001_",correctTrackVersionString,".svg"))

}

selectStrains <- function(trackDataCollector, strainList) {
  # grep a whole list of patterns: http://stackoverflow.com/questions/7597559/grep-in-r-with-a-list-of-patterns
  selectedStrains <- grep(paste(stranList,collapse="|"), trackDataCollector$sampleID)
  trackDataCollector <- trackDataCollector[selectedStrains, ]
  return (trackDataCollector)

}



# global parameters (use <<- instead of <-)
correctTrackVersionString <<- "trackVersion.v13"
TrackLengthSummarizerVersion <<- 2

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

# allways load all sets
trackDataCollector <- loadTracks("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/")
save(trackDataCollector, file = "/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/trackDataCollector_All.rda")  

#trackDataCollector<-censorData(trackDataCollector,"/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/censoringList.txt")

#createPlots(trackDataCollector,"/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/")
#plotSurvival(sortedFilteredCensoredRapidData)
#plotAnova(groupwiseDataCollector_statData)
#plotMeanStDev(groupwiseDataCollector_statData)
