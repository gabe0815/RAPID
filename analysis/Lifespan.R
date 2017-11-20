
extractLifepsan <- function(trackDataCollector, bySet) {
  if (bySet == TRUE){
    # treat each set differently 
    trackDataCollector$groupID <- paste0(trackDataCollector$groupID,"_", trackDataCollector$setID)
  }

  
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
  return (lastTimeAlive)
}

plotSurvival <- function(trackDataCollector, ResultOutputPath, bySet) {
  if (bySet == TRUE){
    # treat each set differently 
    trackDataCollector$groupID <- paste0(trackDataCollector$groupID,"_", trackDataCollector$setID)
  }

  
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
  save(lastTimeAlive, file = "/home/jhench/mac/Documents/sync/lab_journal/2017/data201701/Figure_FUdR_on_N2/lastTimeAlive.rda")
  # calculate mean temperature
  trackDataCollector$temperatureAssay <- as.numeric(trackDataCollector$temperatureAssay)
  trackDataCollector$temperatureTable <- as.numeric(trackDataCollector$temperatureTable)  
  meanTemperatures <- aggregate(temperatureTable ~ groupID, trackDataCollector, mean)
  print(meanTemperatures)
  # plotting
  lastTimeAlive$status <- 1
#  save(lastTimeAlive, file="/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/lastTimeAlive.rda")
  fit<- survfit(Surv(days, status) ~ groupID, data = lastTimeAlive)
  logRank <- survdiff(Surv(days, status) ~ groupID, data = lastTimeAlive)
  ggsurv <- ggsurvplot(fit, 
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
                    #pval = TRUE,
              pval.coord = c(5, 0.25)
             )

#  ggsurv$plot <-ggsurv$plot + geom_hline(aes(yintercept=0.5))    
  print(ggsurv)
  print(logRank)
  ggsave(paste0(ResultOutputPath,"Surv001_",correctTrackVersionString,".svg"), width=7, height=5)

}

selectStrains <- function(trackDataCollector, strainList, bySet) {
  if (bySet == TRUE){
    # treat each set differently 
    trackDataCollector$groupSet <- paste0(trackDataCollector$groupID,"_", trackDataCollector$setID)

    # grep a whole list of patterns: http://stackoverflow.com/questions/7597559/grep-in-r-with-a-list-of-patterns
    selectedStrains <- grep(paste(strainList,collapse="|"), trackDataCollector$groupSet)
  } else {

    # grep a whole list of patterns: http://stackoverflow.com/questions/7597559/grep-in-r-with-a-list-of-patterns
    selectedStrains <- grep(paste(strainList,collapse="|"), trackDataCollector$groupID)
  }
  
  trackDataCollector <- trackDataCollector[selectedStrains, ]
  return (trackDataCollector)

}

