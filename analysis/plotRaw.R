
load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/trackDataCollector_All_censored.rda")
trackDataCollector$groupID <- paste0(trackDataCollector$groupID,"_", trackDataCollector$setID)

p <- ggplot(trackDataCollector, aes(x=days, y=afterArea)) + geom_point(size=0.1)
p + xlim(1, 25) +ylim(0, 40000) + stat_smooth() + facet_wrap(~groupID, ncol=6)

load("/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/strainsAfterAreaMean.rda")
cols.num <- c("days", "afterArea", "sdAfter")
strainsAfterAreaMean[cols.num] <- sapply(strainsAfterAreaMean[cols.num],as.character)
strainsAfterAreaMean[cols.num] <- sapply(strainsAfterAreaMean[cols.num],as.numeric)
p <- ggplot(strainsAfterAreaMean, aes(x=days, y=afterArea)) + geom_point(size=0.1)
p + xlim(1, 25) +ylim(0, 40000) + facet_wrap(~groupID, ncol=6)
