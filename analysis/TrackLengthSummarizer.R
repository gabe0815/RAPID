# track length summarizer and plotter for RAPID data
# 2016 Institut fuer Pathologie, USB, Basel
# J. Hench and G. Schweighauser
#-------------------------------------------------------------------

# tested and developed with:
#  R version 3.0.2 (2013-09-25) -- "Frisbee Sailing"
#  Platform: x86_64-pc-linux-gnu (64-bit)

summarizeTracks <- function(RapidInputPath,ResultOutputPath){
	print(RapidInputPath)
	print(ResultOutputPath)
	cat("loading directory structure to RAM...")
	trackDataCollector <- NULL # reset the list
	rapidDirectories <- list.dirs(RapidInputPath, recursive=FALSE)
	cat(" done.\n")
	cat("collecting data from RAPID datasets:\n")
	cat("|0%.......................100%|\n")
	progressBar <- txtProgressBar(min = 1, max = length(rapidDirectories), initial = 1, char = "=",width = 30, title, label, style = 1, file = "")
	for (d in 1:length(rapidDirectories)){
		pathDirs <- strsplit(rapidDirectories[d], "/", fixed = FALSE, perl = FALSE, useBytes = FALSE)	
		datapointDir <- pathDirs[[1]][length(pathDirs[[1]])] # it's a list!
		if (substring(datapointDir,1,2) == "dl"){ # prefix for datapoint directories	
			inputFiles <- list.files(path = rapidDirectories[d], pattern = NULL, all.files = FALSE, full.names = FALSE, recursive = FALSE, ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
			hit <- 0
			#censor <- 0
			trackCensoredBefore <- NA # default: do not censor
			trackCensoredAfter <- NA # default: do not censor
			if (length(inputFiles)>2){
				for (f in 1:length(inputFiles)){
					if (inputFiles[f] == "trackLength.tsv"){ #required files for analysis
						trackFilePath <- paste0(rapidDirectories[d],"/",inputFiles[f], collapse = NULL)
						hit<-hit+1
					} else if(inputFiles[f] == "sampleID.txt"){ #required files for analysis
						sampleIDFilePath <- paste0(rapidDirectories[d],"/",inputFiles[f], collapse = NULL)
						hit<-hit+1
					} else if(inputFiles[f] == "timestamp.txt"){ #required files for analysis
						timestampFilePath <- paste0(rapidDirectories[d],"/",inputFiles[f], collapse = NULL)
						hit<-hit+1
					}else if (inputFiles[f] == "censored.txt"){ # presence of this file indicates that this timepoint has been manually censored. 
				    #censor<-1 #read censored.txt for before and after and censor for both data sets
					  #censoringFilePath <- paste0(rapidDirectories[d],"/",inputFiles[f], collapse = NULL)
					  censoringParameters<-read.delim(paste0(rapidDirectories[d],"/",inputFiles[f], collapse = NULL), header=FALSE, row.names=1) # read tab-separated data
					  trackCensoredBefore <- censoringParameters["before",]
					  trackCensoredAfter <- censoringParameters["after",]
				  }
				}
			}
			#if (hit == 3 && censor==0){
			if (hit == 3){
				trackDataStrings <- 0
				trackDataStrings <- try(analyzeSingleTrack(sampleIDFilePath,trackFilePath,timestampFilePath),silent=TRUE) #some datasets are garbage
					if (trackDataStrings != 0){
					  trackDataStrings <- c(trackDataStrings, trackCensoredBefore, trackCensoredAfter)
					  #print(trackDataStrings)
					  appendLine <- 0
					for (l in 1:length(trackDataCollector)){ # determine whether strain ID exists (i.e. first element per "row" e.g. IFP140_212 => needs clipping after IFP140)
						if (length(trackDataCollector)>=1){
							if(is.na(trackDataCollector[[l]][1])==FALSE){
								if(trackDataCollector[[l]][1]==trackDataStrings[1]){ 
									appendLine <- l
								}
							}
						}
					}
					if (appendLine > 0){
						trackDataCollector[[appendLine]]<-c(trackDataCollector[[appendLine]],trackDataStrings) # append to existing "row"
					} else {
						trackDataCollector<-lappend(trackDataCollector,trackDataStrings)
					}
				}				
			}
		}
		setTxtProgressBar(progressBar,d)
	}
	cat(" done.\n")
	save(trackDataCollector, file=paste0(ResultOutputPath,"trackDataCollector.rda"))
	#createPlots(trackDataCollector,ResultOutputPath)
}

analyzeSingleTrack <- function(FsampleID,FtrackLength,Ftimestamp){ # this function reads the ASCII files for single timepoints that contain all data (as a tsv file)
	rawTrackLength <- read.delim(FtrackLength,header = TRUE, sep = "\t")
	rawSampleID <- readLines(FsampleID)
	rawTimestamp <- readLines(Ftimestamp)
	sampleID <- rawSampleID[1] # 1st line: sample ID
	birthTimeStamp <- rawSampleID[2] # 2nd line: UNIX timestamp
	currentTimestamp <- rawTimestamp[1] # 1st line: UNIX timestamp
	

	
	trackLengthBefore <- -1
	trackAreaBefore <- -1
	trackEdgeBefore <- -1
	trackContoursBefore <- -1
	trackLengthAfter <- -1
	trackAreaAfter <- -1
	trackEdgeAfter <- -1
	trackContoursAfter <- -1
  trackVersion <- NA
	
  trackVersion <- names(rawTrackLength)[1]
  if (trackVersion == correctTrackVersionString){ #only read files with the correct track version string (defined as global variable correctTrackVersionString)
  	for (l in 1:2){
  		if (is.na(rawTrackLength[[1]][l])==FALSE){
  			if(rawTrackLength[[1]][l] == "before"){
  				trackLengthBefore <- rawTrackLength[['length']][l]
  				trackAreaBefore <- rawTrackLength[['area']][l]
  				trackEdgeBefore <- rawTrackLength[['edge']][l]
  				trackContoursBefore <- rawTrackLength[['contours']][l]
  			} else if (rawTrackLength[[1]][l] == "after"){
  				trackLengthAfter <- rawTrackLength[['length']][l]	
  				trackAreaAfter <- rawTrackLength[['area']][l]
  				trackEdgeAfter <- rawTrackLength[['edge']][l]
  				trackContoursAfter <- rawTrackLength[['contours']][l]
  			}
  		}
  	}
    return (c(sampleID,birthTimeStamp,currentTimestamp,trackLengthBefore,trackAreaBefore,trackLengthAfter,trackAreaAfter,trackVersion,trackEdgeBefore,trackContoursBefore,trackEdgeAfter,trackContoursAfter))
  }else{
    return (0)
  }
}

createPlots <- function(trackDataCollector,ResultOutputPath){
  sortedFilteredCensoredRapidData <- NULL # reset new data list / frame
  censoredUnzeroedRapidData <- NULL # reset new data list / frame
  includedStrains <- uniqueGroups(trackDataCollector)
  strainNumber <- length(includedStrains)
  numberPlotRows <- ceiling(length(trackDataCollector) / strainNumber)
  plotSortList <- NULL # reset the list
  for (i in 1:strainNumber){
    plotSortList<-lappend(plotSortList,NULL) #expand the list to number of strains
  }
  sampleIDs <- NULL
  try(sampleIDs <- unlist(lapply(strsplit(unlist(lapply(trackDataCollector,"[[",1)),"_", fixed = FALSE, perl = FALSE, useBytes = FALSE),"[[",1))) # list of all sampleIDs in the same order as trackDataCollector
  if (is.null(sampleIDs)==FALSE){
    if(is.null(includedStrains)==FALSE){
      if((length(trackDataCollector)>=1) && (strainNumber>0)){
        for (s in 1:length(trackDataCollector)){ #create a plotting-suitable list, i.e. plot strain1-1, strain2-1, strain3-1, strain1-2, strain2-2, strain3-2, etc.
          for (i in 1:strainNumber){
            if (sampleIDs[s]==includedStrains[i]){
              plotSortList[[i]]<-c(plotSortList[[i]],s)
            }
          }
        }
        maxRow <- 0
        for (i in 1:strainNumber){ # get maximum length per row
          thisLength <- length(plotSortList[[i]])
          if (thisLength>maxRow){
            maxRow <- thisLength
          }
        }
        
        try(png(filename = paste0(ResultOutputPath,"Rplot001_",correctTrackVersionString,".png"), width = 400*strainNumber, height = 400*numberPlotRows, units = "px", pointsize = 14, bg = "white"))
        try(par(mfrow=c(maxRow,strainNumber))) # from http://www.statmethods.net/advgraphs/layout.html
        
        cat("creating <<per worm>> plots:\n")
        cat("|0%.......................100%|\n")
        progressBar <- txtProgressBar(min = 1, max = maxRow, initial = 1, char = "=",width = 30, title, label, style = 1, file = "")
        
        sortedDataListCounter <- 1 # reset counter
        #cat("\nmaxRow",maxRow)
        #cat("\nstrainNumber",strainNumber)
        for (o in 1:maxRow){
          for (i in 1:strainNumber){
            #cat("\nplotSortList[[i]][o]",plotSortList[[i]][o])
            s <- plotSortList[[i]][o]
            if(is.na(s)==FALSE){
              #cat("\ntrackDataCollector[[s]]",trackDataCollector[[s]])
              if (is.na(trackDataCollector[[s]])==FALSE){
                numberColumns <- 14 # entries per data point: sampleID,birthTimeStamp,currentTimestamp,trackLengthBefore,trackAreaBefore,trackLengthAfter,trackAreaAfter,trackVersion,trackEdgeBefore,trackContoursBefore,trackEdgeAfter,trackContoursAfter, trackCensoredBefore, trackCensoredAfter
                numberRows<-length(trackDataCollector[[s]])/numberColumns
                if (numberRows==round(numberRows)){
                  thisSample<- matrix(data=trackDataCollector[[s]],nrow=numberRows,ncol=numberColumns,byrow=TRUE,dimnames=NULL) 
                  thisSampleFrame<-transform(data.frame(thisSample), X2 = strtoi(X2), X3 = strtoi(X3), X4 = strtoi(X4), X5 = strtoi(X5), X6 = strtoi(X6), X7 = strtoi(X7), X8 = (strtoi(X3)-strtoi(X2))/3600/24) # convert numeric values to integers, i.e. columns 2-7
                  thisSampleSorted <- mat.sort(thisSampleFrame,3) #sort each sample by "currentTimestamp", i.e. column 3
                  thisSampleSorted <- removeCensored(thisSampleSorted) 
                  thisSampleSorted <- removeEmptyTimepoints(thisSampleSorted)
                  tryCatch({censoredUnzeroedRapidData[[sortedDataListCounter]] <- c(toString(thisSampleSorted[[1]][1]),approx(thisSampleSorted[,8],thisSampleSorted[,columToAnalyze],xout=seq(0,21,1/24)))},error=function(cond){print(paste0("faulty dataset in trackDataCollector[[",toString(s),"]] ",cond))})
                  par(mfg=c(o,i)) #define plotting location on muliple plot sheet http://stackoverflow.com/questions/4785657/r-how-to-draw-an-empty-plot
                  #try(plot(approx(thisSampleSorted[,8],thisSampleSorted[,6],xout=seq(0,16,1/24)),main=thisSampleSorted[[1]][1],xlab="time [days]", ylab="track length [px]",pch='.',type="l",ylim=c(0,1500))) # plotting limits!
                  try(plot(censoredUnzeroedRapidData[[sortedDataListCounter]],main=thisSampleSorted[[1]][1],xlab="time [days]", ylab="track length [px]",pch='.',type="l",ylim=c(0,40000))) # plotting limits!
                  #cat("\nplotting",censoredUnzeroedRapidData[[sortedDataListCounter]],main=thisSampleSorted[[1]][1])
                  sortedFilteredCensoredRapidData[[sortedDataListCounter]] <- thisSampleSorted
                  sortedDataListCounter <- sortedDataListCounter + 1
                }
              }
            }
          }
          setTxtProgressBar(progressBar,o)
        }

        cat("... done.\n")
        cat("writing plots to file ...")
        dev.off()
        cat(" done.\n")
        cat("saving <<censoredUnzeroedRapidData>> to file ...")
        #print(censoredUnzeroedRapidData)
        save(censoredUnzeroedRapidData, file=paste0(ResultOutputPath,"censoredUnzeroedRapidData.rda"))
        cat(" done.\n")
        cat("saving <<sortedFilteredCensoredRapidData>> to file ...")
        save(sortedFilteredCensoredRapidData, file=paste0(ResultOutputPath,"sortedFilteredCensoredRapidData.rda"))
      } #end of error check
    } #end of is.null clause
  } #end of (another) is.null clause
  cat(" done.\n")
}

censorData <- function(trackDataCollector,censoringList){
	cat("\ncensoring data...\n")
	censNames <- readLines(censoringList)
	cat("|0%.......................100%|\n")
	newTrackDataCollector <- NULL
	progressBar <- txtProgressBar(min = 1, max = length(trackDataCollector), initial = 1, char = "=",width = 30, title, label, style = 1, file = "")
	for (i in 1:length(trackDataCollector)){
		if ((trackDataCollector[[i]][1] %in% censNames) == FALSE){
			newTrackDataCollector<-c(newTrackDataCollector,trackDataCollector[i])
		}
		setTxtProgressBar(progressBar,i)
	}
	cat(" done.\n")
	return(newTrackDataCollector)	
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
	strainNumber <- 0
	sampleIDs <- NULL
	try(sampleIDs<-unique(unlist(lapply(strsplit(unlist(lapply(trackDataCollector,"[[",1)),"_", fixed = FALSE, perl = FALSE, useBytes = FALSE),"[[",1)))) #sampleIDs<-unlist(lapply(trackDataCollector,"[[",1)) #sampleIDs<-strsplit(sampleIDs,"_", fixed = FALSE, perl = FALSE, useBytes = FALSE) #sampleIDs<-unlist(lapply(sampleIDs,"[[",1)) #sampleIDs<-unique(sampleIDs)
	if (is.null(sampleIDs)==FALSE){
  	censorList <- NULL
  	for (i in 1:length(sampleIDs)){
  		if (length(grep("Error",sampleIDs[i]))>0){ # Sometimes datasets throw an error during reading of the text files which results in the word "Error" in the string.
  			censorList <- c(censorList,i)
  		}
  	}
  	if (length(censorList)>0){
  		sampleIDs<-sampleIDs[-censorList]
  	}
  	cat("The current data set contains",length(sampleIDs),"samples:",sampleIDs,"\n")
	}
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

checkTimePoints <- function(singleSampleFrame){
    #get the last timepoint, a worm was moving
    for(i in nrow(singleSampleFrame):1){
        if ((singleSampleFrame[i,columToAnalyze] != 0) && (singleSampleFrame[i,columToAnalyze] != -1)){
            #cat("last timepoint: ", singleSampleFrame[i,8])
            return (singleSampleFrame[i,8])
            break
        }
    }
    return (-1)
}

plotSurvival <- function(sortedFilteredCensoredRapidData) {
  library(survminer)
  library(survival)
  # At the moment, the column to be checked is hardcoded (X7). This could be avoided if we proberly name columns.
  # All worms are collected in the same data frame. By having a group ID, they can be assigned during plotting.
  lastTimeAlive.df <- data.frame(ID = character(0), group = character(0), stop = numeric(0), status = numeric(0))  
  for (i in 1:length(sortedFilteredCensoredRapidData)){
    for (j in length(sortedFilteredCensoredRapidData[[i]]$X7):1){
       if ((sortedFilteredCensoredRapidData[[i]]$X7[j] != 0) && (sortedFilteredCensoredRapidData[[i]]$X7[j] != -1)){
         lastTimeAlive.df <- rbind(lastTimeAlive.df, data.frame(ID = as.character(sortedFilteredCensoredRapidData[[i]]$X1[j]), 
                                                             group = unlist(strsplit(as.character(sortedFilteredCensoredRapidData[[i]]$X1[j]), "_"))[1], 
                                                              stop = sortedFilteredCensoredRapidData[[i]]$X8[j], 
                                                            status = 1))
         break
       } 
    }
  } 

#  png(filename = "/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/survival.png",
#         width = 480, 
#        height = 480, 
#         units = "px", 
#     pointsize = 12,
#            bg = "white"
#      )

  fit<- survfit(Surv(stop, status) ~ group, data = lastTimeAlive.df)
  ggsurvplot(fit)
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
load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160902_vibassay_set11/trackDataCollector.rda")
#tracks11 <- trackDataCollector
#load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_20160919_vibassay_set12/trackDataCollector.rda")
#trackDataCollector<-c(tracks2,tracks3,tracks4,tracks5,tracks6,tracks7,tracks8,tracks9)
#trackDataCollector<-tracks10
# trackDataCollector<-c(tracks2,tracks3,tracks5)
##load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/Rdata_SS104_set2_analysisV13/trackDataCollector.rda")


      #print(trackDataCollector[[length(trackDataCollector)]])
      #print(typeof(trackDataCollector))
      #print(length(trackDataCollector))
      #print("------------------------")

trackDataCollector<-censorData(trackDataCollector,"/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/censoringList.txt")


      #print(trackDataCollector[[length(trackDataCollector)]])
      #print(typeof(trackDataCollector))
      #print(length(trackDataCollector))
      #print("------------------------")
      #load("trackDataCollector.rda")
      #createMeanPlots(trackDataCollector,"/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/")

createPlots(trackDataCollector,"/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/")

# next 3 lines WORK!
#load("/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/censoredUnzeroedRapidData.rda")
load("/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/sortedFilteredCensoredRapidData.rda")
plotSurvival(sortedFilteredCensoredRapidData)


##groupwiseDataCollector_statData<-createMeanPlots(censoredUnzeroedRapidData,"/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/")

##save(groupwiseDataCollector_statData, file="/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/groupwiseDataCollector_statData.rda")
##load("/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/groupwiseDataCollector_statData.rda")

##plotAnova(groupwiseDataCollector_statData)
##plotMeanStDev(groupwiseDataCollector_statData)
