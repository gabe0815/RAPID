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
        before <- unlist(unname(rawTrackLength[beforeIdx,2:5])) # length area edge contours
        after <- unlist(unname(rawTrackLength[afterIdx,2:5]))          
				
			} else if (inputFiles[f] == "sampleID.txt"){ #required files for analysis
        rawSampleID <- readLines(filePath)
        sampleID <- rawSampleID[1]
        birthTimestamp <- rawSampleID[2]
				
			} else if (inputFiles[f] == "timestamp.txt"){ #required files for analysis
				currentTimestamp <- readLines(filePath)
				
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
            temperatureAssay <- rawTemperature[1,1]
            temperatureTable <- rawTemperature[1,2]
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
	save(trackDataCollector, file=paste0(ResultOutputPath,"trackDataCollector.rda"))  
}


createPlots <- function(trackDataCollector,ResultOutputPath){
  # calculate age of the worms in days
  trackDataCollector$days <- ((as.numeric(trackDataCollector$currentTimestamp) - as.numeric(trackDataCollector$birthTimestamp))/(3600 * 24))  

  # instead of deleting the censored data points, we can write them as NA and use na.omit to omit them during plotting.
  censorBefore <- c(which(trackDataCollector$beforeEdge == 1), which(trackDataCollector$censorBefore == 1), which(trackDataCollector$beforeArea == -1))
  trackDataCollector$beforeArea[censorBefore] <- NA
  censorAfter <- c(which(trackDataCollector$afterEdge == 1), which(trackDataCollector$censorAfter == 1), which(trackDataCollector$afterArea == -1))
  trackDataCollector$afterArea[censorAfter] <- NA

  # figure out how big the plot will be  
  includedStrains <- uniqueGroups(trackDataCollector)
  strainNumber <- length(includedStrains)

  # figure out which group has the most individuals
  for (i in includedStrains){
    numberOfWorms <- c(numberOfWorms, unique(trackDataCollector[grep(i, trackDataCollector$sampleID), ]))
  }
  numberPlotRows <- max(numberOfWorms
  
  # create an empty canvas with size unique groups x maximum number of individuals
 try(png(filename = paste0(ResultOutputPath,"Rplot001_",correctTrackVersionString,".png"), width = 200*strainNumber, height = 200*numberPlotRows, units = "px", pointsize = 14, bg  = "white"))
 try(par(mfrow=c(numberPlotRows, strainNumber))) # from http://www.statmethods.net/advgraphs/layout.html
  
  # go through the unique groups
  for (x in 1:length(includedStrains)){
    wormsPerStrain <- trackDataCollector[grep(includedStrains[x], trackDataCollector$sampleID), ]
    for (y in 1:length(unique(wormsPerStrain$sampleID))){
      singleWorm <- wormsPerStrain[grep(wormsPerStrain$sampleID[y], wormsPerStrain$sampleID),]
      # do the plot at x,y on canvas

    par(mfg=c(y,x)) # define plotting location on muliple plot sheet http://stackoverflow.com/questions/4785657/r-how-to-draw-an-empty-plot
    try(plot(singleWorm$days, singleWorm$afterArea,main=wormsPerStrain$sampleID[y],xlab="time [days]", ylab="track length [px]",pch='.',type="l",ylim=c(0,40000))) # plotting limits!

     } 
   }
   cat("... done.\n")
   cat("writing plots to file ...")
   dev.off()
   cat(" done.\n")

}

censorData <- function(trackDataCollector,censoringList){
	cat("\ncensoring data...\n")
	censNames <- readLines(censoringList)
  trackDataCollectorCensored <- trackDataCollector[!trackDataCollector$sampleID %in% censNames, ]
	cat(" done.\n")
	return(trackDataCollectorCensored)	
}

createMeanPlots <- function(censoredUnzeroedRapidData,ResultOutputPath){
	#timeUnit <- 3600 # 1 hour (in s - UNIX timestamps)
	sampleGroups <- uniqueGroups(trackDataCollector)
	#print("sampleGroups")
	#print(sampleGroups)
	statData <- NULL # empty list
	groupwiseDataCollector <- data.frame(internalIndex=numeric(length(sampleGroups))) #strainGroup=character(length(sampleGroups)),listSamples=numeric(length(sampleGroups)),numberSamples=numeric(length(sampleGroups))) # create an empty list

	print(groupwiseDataCollector)
	#stdTimeList <- censoredUnzeroedRapidData[[1]]$x # create a timepoint list
	#timewiseDataCollector <- data.frame(timePoint=numeric(length(stdTimeList))) # create a data frame with one column, containing all timepoints
	columnNames <- NULL #empty list
	for (i in 1:length(sampleGroups)){
	  print(sampleGroups[i])
		columnNames[[i]]<-sampleGroups[i]
		columnNames[[i+length(sampleGroups)]] <- paste0(sampleGroups[i],"_mean")
		columnNames[[i+length(sampleGroups)*2]] <- paste0(sampleGroups[i],"_median")
		columnNames[[i+length(sampleGroups)*3]] <- paste0(sampleGroups[i],"_average")
	}
	
	print("columnNames")
	print(columnNames)
	
	emptyValueList <- rep(0,length(censoredUnzeroedRapidData[[1]]$x)) # create list of 0s as long as the timepoint list
	print(sampleGroups)
	for (i in 1:length(sampleGroups)){
		groupwiseDataCollector$internalIndex[i] <- i
		groupwiseDataCollector$strainGroup[i] <- sampleGroups[i] # replace strain name field with sample group name (to be used as search filter later and for plotting
		groupwiseDataCollector$listSamples[[i]] <- list()
		groupwiseDataCollector$numberSamples[i] <- 0
		groupwiseDataCollector$nameSamples[[i]] <- list()
	}
	
	print(groupwiseDataCollector)
	for (j in 1:length(censoredUnzeroedRapidData)){
		for (i in 1:length(sampleGroups)){
  		if(is.na(groupwiseDataCollector$strainGroup[i])==FALSE && is.na(censoredUnzeroedRapidData[[j]][1])==FALSE){
		  	if(grepl(groupwiseDataCollector$strainGroup[i],censoredUnzeroedRapidData[[j]][1]) == TRUE){
  				statData[[j]]<-censoredUnzeroedRapidData[[j]]$y # $y values, track length
  				groupwiseDataCollector$listSamples[[i]] <- c(groupwiseDataCollector$listSamples[[i]],j)
  				groupwiseDataCollector$nameSamples[[i]] <- c(groupwiseDataCollector$nameSamples[[i]],censoredUnzeroedRapidData[[j]][1])
  				groupwiseDataCollector$numberSamples[i] <- groupwiseDataCollector$numberSamples[i]+1
		  	}
  		}
		}
	}
		
	print(groupwiseDataCollector)
	cat("\nThe data set contains these sample groups: ",sampleGroups,"\n")
    #This loop does nothing?	
    for (i in 2:length(censoredUnzeroedRapidData)){
		for (j in 1:length(sampleGroups)){
			
		}
	}
	return(list(groupwiseDataCollector,statData,censoredUnzeroedRapidData[[1]]$x))
}

performAnova <- function(groupwiseDataCollector_statData,timePoint){
  anovaDataFrame <- data.frame(wormID=character(0), motionValue=numeric(0), strainID=character(0))
  anovaDataFrame[nrow(anovaDataFrame)+1,] <- NA #expand data frame for 1 row
  anovaDataFrame$wormID <- "" #empty row (somehow necessary)
  anovaDataFrame$motionValue <- 0 #empty row (somehow necessary)
  anovaDataFrame$strainID <- "" #empty row (somehow necessary)
  for(i in 1:length(groupwiseDataCollector_statData[1][[1]]$internalIndex)){ # strains
   for(j in 1:length(unlist(groupwiseDataCollector_statData[1][[1]]$listSamples[i]))){ # worms
     r<-nrow(anovaDataFrame)
     anovaDataFrame$wormID[r] <- groupwiseDataCollector_statData[[1]]$nameSamples[[i]][[j]]
     anovaDataFrame$motionValue[r] <- groupwiseDataCollector_statData[2][[1]][groupwiseDataCollector_statData[[1]]$listSamples[[i]][[j]]][[1]][timePoint]
     anovaDataFrame$strainID[r] <- groupwiseDataCollector_statData[[1]]$strainGroup[[i]]
     anovaDataFrame[nrow(anovaDataFrame)+1,] <- NA #expand data frame for 1 row
    }
  }
  anovaDataFrame <- anovaDataFrame[-c(nrow(anovaDataFrame)), ] #remove last = empty row
  anovaDataFrame$wormID <- factor(anovaDataFrame$wormID)
  aov1 <- aov(motionValue ~ strainID, data=anovaDataFrame)
  anovaResult <- data.frame(TukeyHSD(aov1)[1])
  return(anovaResult)
}

calcMeanStd <- function(groupwiseDataCollector_statData,timePoint){
  meanDataFrame <- data.frame(wormID=character(0), motionValue=numeric(0), strainID=character(0))
  meanDataFrame[nrow(meanDataFrame)+1,] <- NA #expand data frame for 1 row
  meanDataFrame$wormID <- "" #empty row (somehow necessary)
  meanDataFrame$motionValue <- 0 #empty row (somehow necessary)
  meanDataFrame$strainID <- "" #empty row (somehow necessary)
  for(i in 1:length(groupwiseDataCollector_statData[1][[1]]$internalIndex)){ # strains
    for(j in 1:length(unlist(groupwiseDataCollector_statData[1][[1]]$listSamples[i]))){ # worms
      r<-nrow(meanDataFrame)
      meanDataFrame$wormID[r] <- groupwiseDataCollector_statData[[1]]$nameSamples[[i]][[j]]
      meanDataFrame$motionValue[r] <- groupwiseDataCollector_statData[2][[1]][groupwiseDataCollector_statData[[1]]$listSamples[[i]][[j]]][[1]][timePoint]
      meanDataFrame$strainID[r] <- groupwiseDataCollector_statData[[1]]$strainGroup[[i]]
      meanDataFrame[nrow(meanDataFrame)+1,] <- NA #expand data frame for 1 row
    }
  }
  meanDataFrame <- meanDataFrame[-c(nrow(meanDataFrame)), ] #remove last = empty row
  meanStdResult <- data.frame(matrix(NA, nrow = 2, ncol = length(unlist(groupwiseDataCollector_statData[[1]][2]))))# empty data frame with strains as column labels
  colnames(meanStdResult)<-unlist(groupwiseDataCollector_statData[[1]][2]) # set strain names as column names
  rownames(meanStdResult)<-c("mean","stDev")
  for (s in unlist(groupwiseDataCollector_statData[[1]][2])){ # collect data for each strain separately, i.e. loop through strain by strain
    motionValues <- meanDataFrame[meanDataFrame$strainID==s,]$motionValue
    meanStdResult["mean",s]<-mean(motionValues)
    meanStdResult["stDev",s]<-sd(motionValues)
  }
  return(meanStdResult)
}

plotAnova <- function(groupwiseDataCollector_statData){
  plotSampleNumber <- choose(length(unlist(groupwiseDataCollector_statData[[1]][2])),2) # determine how many comparisons will be available (at most) with the included strain list -> choose(n,k) N over K
  print(plotSampleNumber)
  plotWidth <- ceiling(sqrt(plotSampleNumber))
  plotHeight <- ceiling(plotSampleNumber/plotWidth)
  ResultOutputPath <-"/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/"
  png(filename = paste0(ResultOutputPath,"ANOVAplot001_",correctTrackVersionString,".png"), width = 400*plotWidth, height = 400*plotHeight, units = "px", pointsize = 14, bg = "white")
  par(mfrow=c(plotWidth,plotHeight),pty = "s") #define plotting location on muliple plot sheet http://stackoverflow.com/questions/4785657/r-how-to-draw-an-empty-plot
  anovaDataCollector <- NULL
  cat("calculating ANOVA:\n")
  cat("|0%.......................100%|\n")
  #print(groupwiseDataCollector_statData)
  progressBar <- txtProgressBar(min = 1, max = length(groupwiseDataCollector_statData[2][[1]][[1]]), initial = 1, char = "=",width = 30, title, label, style = 1, file = "")
  for (q in 1:length(groupwiseDataCollector_statData[2][[1]][[1]])){ #loop through all virtual time points
  #for (q in 190:191){
    setTxtProgressBar(progressBar,q)
    anovaResult <- NULL
    try(anovaResult <- performAnova(groupwiseDataCollector_statData,q),silent = TRUE)
    if (is.null(anovaResult) == FALSE){
      if(length(anovaResult$strainID.p.adj) == plotSampleNumber){ #test if all samples are available for this timepoint
        if(is.null(anovaDataCollector)==TRUE){ #create a new data frame by copying and cleaning up the anovaResult data frame
          anovaDataCollector <- anovaResult
          anovaDataCollector$strainID.diff<-NULL
          anovaDataCollector$strainID.lwr <-NULL
          anovaDataCollector$strainID.upr <-NULL
          anovaDataCollector$strainID.p.adj <-NULL
        }
        anovaDataCollector[length(anovaDataCollector)+1] <- anovaResult$strainID.p.adj
        colnames(anovaDataCollector)[length(anovaDataCollector)] <- groupwiseDataCollector_statData[3][[1]][q]
      }
    }
  }
  cat("... done.\n")
  save(anovaDataCollector, file="/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/anovaDataCollector.rda")
  #load(file="/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/anovaDataCollector.rda")
  
  anovaRowNames <- rownames(anovaDataCollector)
  anovaColNames <- as.numeric(colnames(anovaDataCollector))
  cat("plotting ANOVA:\n")
  cat("|0%.......................100%|\n")
  progressBar <- txtProgressBar(min = 1, max = length(anovaRowNames), initial = 1, char = "=",width = 30, title, label, style = 1, file = "")
  for (i in 1:length(anovaRowNames)){
    plotX <- anovaColNames
    plotY <- anovaDataCollector[i,]
    plot(xy.coords(plotX, plotY, log="y"), log="y",main=anovaRowNames[i],xlab="time [days]", ylab="p-value [ANOVA]",pch='.',type="l",xlim=c(0,25),ylim=c(0.00000001,1))
    lines(c(0,100),c(0.05,0.05),col="red")
    setTxtProgressBar(progressBar,i)
  }
  cat("... done.\n")
  cat("writing plots to file ...")
  dev.off()
}

plotMeanStDev <- function(groupwiseDataCollector_statData){
  plotSampleNumber <- length(unlist(groupwiseDataCollector_statData[[1]][2])) # determine how many comparisons will be available (at most) with the included strain list -> choose(n,k) N over K
  print(plotSampleNumber)
  plotWidth <- plotSampleNumber
  plotHeight <- 1
  ResultOutputPath <-"/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/"
  
  meanCollector <- data.frame(matrix(NA, nrow = length(groupwiseDataCollector_statData[[3]]), ncol = length(unlist(groupwiseDataCollector_statData[[1]][2])))) #create an empty data frame filled with NA
  colnames(meanCollector)<-unlist(groupwiseDataCollector_statData[[1]][2]) # set strain names as column names
  rownames(meanCollector)<-groupwiseDataCollector_statData[[3]]
  stdevCollector <- meanCollector #duplicate the NA data frame
  
  cat("calculating Mean and StDev:\n")
 # cat("|0%.......................100%|\n")
 # progressBar <- txtProgressBar(min = 1, max = length(groupwiseDataCollector_statData[2][[1]][[1]]), initial = 1, char = "=",width = 30, title, label, style = 1, file = "")
  
  for (q in 1:length(groupwiseDataCollector_statData[[3]])){ #loop through all virtual time points
  #for (q in 190:193){
    #setTxtProgressBar(progressBar,q)
    meanStdResult <- NULL
    try(meanStdResult<- calcMeanStd(groupwiseDataCollector_statData,q),silent = FALSE)
    if (is.null(meanStdResult) == FALSE){
      if(length(meanStdResult) == plotSampleNumber){ #test if all samples are available for this timepoint
          meanCollector[q,] <- meanStdResult["mean",]
          stdevCollector[q,] <- meanStdResult["stDev",]  
      }
    }
  }
  cat("... done.\n")
  
  save(meanCollector, file="/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/meanCollector.rda")
  save(stdevCollector, file="/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/stdevCollector.rda")
  #load(file="/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/meanCollector.rda")
  #load(file="/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/stdevCollector.rda")
  
  png(filename = paste0(ResultOutputPath,"MEANplot001_",correctTrackVersionString,".png"), width = 400*plotWidth, height = 400*plotHeight, units = "px", pointsize = 14, bg = "white")
  par(mfrow=c(plotHeight,plotWidth),pty = "s") #define plotting location on muliple plot sheet http://stackoverflow.com/questions/4785657/r-how-to-draw-an-empty-plot
  plotX <- as.numeric(rownames(meanCollector))
  cat("plotting mean:\n")
#  cat("|0%.......................100%|\n")
#  progressBar <- txtProgressBar(min = 1, max = length(meanCollector), initial = 1, char = "=",width = 30, title, label, style = 1, file = "")
  for (i in 1:length(colnames(meanCollector))){
    plotY <- meanCollector[,i] # entire colun of current strain over time
    plot(xy.coords(plotX[is.na(plotY)==FALSE], plotY[is.na(plotY)==FALSE]),main=colnames(meanCollector)[i],xlab="time [days]", ylab="mean [track]",pch='.',type="l",xlim=c(0,25),ylim=c(0,40000)) #plot needs to exlude NA rows
#    setTxtProgressBar(progressBar,i)
  }
  cat("... done.\n")
  cat("writing plots to file ...")
  dev.off()
  
  cat("plotting stdev:\n")
#  cat("|0%.......................100%|\n")
#  progressBar <- txtProgressBar(min = 1, max = length(meanCollector), initial = 1, char = "=",width = 30, title, label, style = 1, file = "")
  png(filename = paste0(ResultOutputPath,"STDEVplot001_",correctTrackVersionString,".png"), width = 400*plotWidth, height = 400*plotHeight, units = "px", pointsize = 14, bg = "white")
  par(mfrow=c(plotHeight,plotWidth),pty = "s") #define plotting location on muliple plot sheet http://stackoverflow.com/questions/4785657/r-how-to-draw-an-empty-plot
  plotX <- as.numeric(rownames(meanCollector))
  for (i in 1:length(colnames(meanCollector))){
    plotY <- stdevCollector[,i] # entire colun of current strain over time
    plot(xy.coords(plotX[is.na(plotY)==FALSE], plotY[is.na(plotY)==FALSE]),main=colnames(meanCollector)[i],xlab="time [days]", ylab="std.dev. [track]",pch='.',type="l",xlim=c(0,25),ylim=c(0,40000))
#    setTxtProgressBar(progressBar,i)
  }
  cat("... done.\n")
  cat("writing plots to file ...")
  dev.off()
  
  cat("plotting mean and stdev:\n")
#  cat("|0%.......................100%|\n")
#  progressBar <- txtProgressBar(min = 1, max = length(meanCollector), initial = 1, char = "=",width = 30, title, label, style = 1, file = "")
  png(filename = paste0(ResultOutputPath,"MEANandSTDEVplot001_",correctTrackVersionString,".png"), width = 400*plotWidth, height = 400*plotHeight, units = "px", pointsize = 14, bg = "white")
  par(mfrow=c(plotHeight,plotWidth),pty = "s") #define plotting location on muliple plot sheet http://stackoverflow.com/questions/4785657/r-how-to-draw-an-empty-plot
  plotX <- as.numeric(rownames(meanCollector))
  for (i in 1:length(colnames(meanCollector))){
    plotY1 <- meanCollector[,i]  # entire colun of current strain over time
    plotY2 <- stdevCollector[,i] # entire colun of current strain over time
    plot(xy.coords(plotX[is.na(plotY1)==FALSE], plotY1[is.na(plotY1)==FALSE]),main=colnames(meanCollector)[i],xlab="time [days]", ylab="speed[a.U.] (black), std.dev.(gray)",pch='.',type="l",xlim=c(0,25),ylim=c(0,40000),col="black")
    lines(plotX[is.na(plotY2)==FALSE], plotY1[is.na(plotY1)==FALSE]-plotY2[is.na(plotY2)==FALSE],col="gray")
    lines(plotX[is.na(plotY2)==FALSE], plotY1[is.na(plotY1)==FALSE]+plotY2[is.na(plotY2)==FALSE],col="gray")
#    setTxtProgressBar(progressBar,i)
  }
  cat("... done.\n")
  cat("writing plots to file ...")
  dev.off()
}


removeEmptyTimepoints <- function(singleSample){
	singleSample <- singleSample[singleSample[,columToAnalyze]<50000,] # upper cut-off X6 <15000
	if(length(singleSample)>1){
		if(length(singleSample[,columToAnalyze])>3){
			rem <- FALSE
			remList <- NULL
			for (i in length(singleSample[,columToAnalyze]):2){ # find first zero y after last positive value
				if((is.na(singleSample[i,columToAnalyze]) == FALSE) && (is.na(singleSample[i-1,columToAnalyze]) == FALSE)){ 
					if((singleSample[i,columToAnalyze]==-1) && (singleSample[i-1,columToAnalyze]>-1) && (rem == FALSE)){  
						rem <- TRUE
					}else if ((rem == TRUE) && (singleSample[i,columToAnalyze]==-1)){
						remList <- c(remList,i)
					}
				}
			}
			if(length(remList) > 0){
				singleSample<-singleSample[-remList,] # http://stackoverflow.com/questions/12328056/how-do-i-delete-rows-in-a-data-frame
			}
		}
	}
	return(singleSample)
}

removeCensored <- function(singleSample){
  #save(singleSample, file="/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/singleSample.rda")
  #set area of censored timepoints to -1, before and after
  if (columToAnalyze == 7){
    censor <- 14
    edge <- 11
  } else if (columToAnalyze == 5){
    censor <- 13
    edge <- 9
  }
  for (i in 1:nrow(singleSample)){
    if (singleSample[i,edge] == 1){
      singleSample[i,columToAnalyze] <- -1 #these will be ignored (track crosses edge)
      #print("edge")
    }
    if (is.na(singleSample[i,censor]) == FALSE){
      if (singleSample[i,censor] == 1){
        singleSample[i,columToAnalyze] <- -1 #these will be ignored 
        #print("censoring")
      }
    }
  }
  return (singleSample)

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

load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_SS104_set2_analysisV13/trackDataCollector.rda")
trackDataCollectorCensored <- censorData(trackDataCollector,"/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/censoringList.txt")
uniqueGroups(trackDataCollectorCensored)
createPlots(trackDataCollectorCensored, "/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/")

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
