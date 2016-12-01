
load("/home/jhench/mac/Documents/sync/lab_journal/2016/data201603/Track_Length_Analysis/trackDataCollector_All_censored.rda")
trackDataCollector$groupID <- paste0(trackDataCollector$groupID,"_", trackDataCollector$setID)
cols.num <- c("temperatureTable", "temperatureAssay")
trackDataCollector[cols.num] <- sapply(trackDataCollector[cols.num],as.character)
trackDataCollector[cols.num] <- sapply(trackDataCollector[cols.num],as.numeric)

load("/mnt/4TBraid04/imagesets04/20160321_FIJI_analysis_testing/strainsAfterAreaMean.rda")
cols.num <- c("days", "afterArea", "sdAfter")
strainsAfterAreaMean[cols.num] <- sapply(strainsAfterAreaMean[cols.num],as.character)
strainsAfterAreaMean[cols.num] <- sapply(strainsAfterAreaMean[cols.num],as.numeric)


# plot raw, temperature, mean and CI in facettes
p <- ggplot(trackDataCollector, aes(x=days, y=afterArea)) + geom_point(size = 0.1, alpha = 0.5, aes(colour = temperatureTable)) + scale_colour_gradientn(colours = rainbow(7)) + stat_smooth(fill = "grey50", size = 0.1, alpha = 1)  + geom_path(data=strainsAfterAreaMean, color = "red")
p + xlim(1, 25) +ylim(0, 40000) + facet_wrap(~groupID, ncol=6)

# plot mean and CI in facettes
p <- ggplot(trackDataCollector, aes(x=days, y=afterArea))
p + stat_smooth(fill = "grey50", size = 0.1, alpha = 1) + xlim(1, 25) +ylim(0, 40000) + facet_wrap(~groupID, ncol=6)

# plot mean and CI in one
p <- ggplot(trackDataCollector, aes(x=days, y=afterArea, group=groupID, colour=groupID))
p + stat_smooth(fill = "grey50", size = 1, alpha = 1) + xlim(1, 25) +ylim(0, 40000)
