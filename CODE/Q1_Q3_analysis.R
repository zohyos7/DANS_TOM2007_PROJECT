## Comparison between Tom et al. (2007) and hBayesDM

rm(list = ls())
library(hBayesDM)
# wd <- "/Users/seonghuncho/tom-data/"
# setwd(wd)
# behav_data_path <- "behav_data/"
# file_list <- dir(paste(wd,behav_data_path,sep=""))
# 
# all_data = NULL 
# for (i in 1:length(file_list)) {
#   tmpData <- read.table(file.path(behav_data_path, file_list[i]), header=T, sep="\t")
#   tmp_subjID <- as.integer(substr(file_list[i], 5, 6))
#   tmpData$subjID <- tmp_subjID
#   all_data <- rbind(all_data, tmpData)  
# }
# all_data$cert <- 0
# all_data <- subset(all_data, respcat >= 0)
# all_data$gamble <- all_data$respcat
# write.table(all_data, "tom2007_behav.txt",col.names = T, row.names = F, sep = "\t")
output1 <- ra_noRA("tom2007_behav.txt", niter=2000, nwarmup=1000,
                   nchain=2, ncore=2, inits="fixed")

# rhat(output1, less = 1.1)
# plot(output1)
# plotInd(output1, "lambda")
# plotInd(output1, "tau")


lambda_Tom = NULL
lambda_Tom_lm = NULL
subjIDs = unique(all_data$subjID)
for (i in 1:length(subjIDs)) {
  tmp_results = glm(gamble ~ gain + loss,  data = all_data, subset = (subjID==subjIDs[i]),
                    family = binomial(link = "logit"))
  tmp_results_lm = lm(gamble ~ gain + loss,  data = all_data, subset = (subjID==subjIDs[i]))
  lambda_Tom[i] = -tmp_results$coefficients[3] / tmp_results$coefficients[2]
  lambda_Tom_lm[i] = -tmp_results_lm$coefficients[3] / tmp_results_lm$coefficients[2]
}

lambda_post <- apply(output1$parVals$lambda,2,mean)
data_ggplot <- data.frame(lambda_Tom,lambda_Tom_lm,lambda_post)
data_ggplot$outlier <- (data_ggplot$lambda_Tom<=6)
fit.lm <- lm(lambda_Tom~lambda_post,subset=outlier,data=data_ggplot)
fit.lm_lm <- lm(lambda_Tom_lm~lambda_post,subset=outlier,data=data_ggplot)

library(ggplot2)
plot0 <- ggplot(data = data_ggplot, aes(x=lambda_post,y=lambda_Tom)) + 
  geom_point(aes(color=outlier),show.legend = F) +
  theme(
    plot.background = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    panel.background = element_blank(),
    axis.line = element_line(size = 0.5),
    plot.title = element_text(hjust=0.5)
  ) + labs(title="Comparison (GLM)",
           x ="Loss aversion (hBayesDM)", y = "Loss aversion (Tom et al, 2007)") +
  geom_abline(slope=fit.lm$coefficients[2], intercept=fit.lm$coefficients[1],lty="dashed") +
  geom_abline(slope=1, intercept=0,lty="dotted")

plot0_lm <- ggplot(data = data_ggplot, aes(x=lambda_post,y=lambda_Tom_lm)) + 
  geom_point(aes(color=outlier),show.legend = F) +
  theme(
    plot.background = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    panel.background = element_blank(),
    axis.line = element_line(size = 0.5),
    plot.title = element_text(hjust=0.5)
  ) + labs(title="Comparison (LM)",
           x ="Loss aversion (hBayesDM)", y = "Loss aversion (Tom et al, 2007)") +
  geom_abline(slope=fit.lm$coefficients[2], intercept=fit.lm$coefficients[1],lty="dashed") +
  geom_abline(slope=1, intercept=0,lty="dotted")

ggsave(filename="comparison_glm.pdf",plot = plot0,width=3.5,height=3.5)
ggsave(filename="comparison_lm.pdf",plot = plot0_lm,width=3.5,height=3.5)

## Heatmap

library(ggplot2)
data_ggplot <- data.frame(gain=rep(6.25 + 7.5*(1:4),4),
                          loss=rep(3.125 + 3.75*(1:4),each=4),
                          gain.min=rep(2.5 + 7.5*(1:4),4),
                          gain.max=rep(10 + 7.5*(1:4),4),
                          loss.min=rep(1.25 + 3.75*(1:4),each=4),
                          loss.max=rep(5 + 3.75*(1:4),each=4))
data_ggplot$gain.max[data_ggplot$gain.max==40] <- 41
data_ggplot$loss.max[data_ggplot$loss.max==20] <- 21
total <- sapply(1:nrow(data_ggplot),function(i){
  sum((data_ggplot$gain.min[i] <= all_data$gain)&(data_ggplot$gain.max[i] > all_data$gain)&
        (data_ggplot$loss.min[i] <= all_data$loss)&(data_ggplot$loss.max[i] > all_data$loss))
})
accept <- sapply(1:nrow(data_ggplot),function(i){
  sum((data_ggplot$gain.min[i] <= all_data$gain)&(data_ggplot$gain.max[i] > all_data$gain)&
        (data_ggplot$loss.min[i] <= all_data$loss)&(data_ggplot$loss.max[i] > all_data$loss)&
        all_data$gamble)
})
resp <- sapply(1:nrow(data_ggplot),function(i){
  mean(all_data$response_time[(data_ggplot$gain.min[i] <= all_data$gain)&
                                (data_ggplot$gain.max[i] > all_data$gain)&
                                (data_ggplot$loss.min[i] <= all_data$loss)&
                                (data_ggplot$loss.max[i] > all_data$loss)])
})
data_ggplot$accept_prob <- accept/total
data_ggplot$resp <- resp

jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F",
                                 "yellow", "#FF7F00", "red", "#7F0000"))
plot1 <- ggplot(data = data_ggplot, aes(x=gain, y=loss, fill=accept_prob)) +
  geom_tile() + scale_y_reverse() +
  scale_fill_gradientn(colours=jet.colors(7),name="") +
  theme(
    plot.background = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    panel.background = element_blank(),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    plot.title = element_text(hjust=0.5)
  ) + labs(title="Probability of acceptance",
           x ="Potential Gain ($)", y = "Potential Loss ($)")

plot2 <- ggplot(data = data_ggplot, aes(x=gain, y=loss, fill=resp)) +
  geom_tile() + scale_y_reverse() +
  scale_fill_gradientn(colours=jet.colors(7),name="") +
  theme(
    plot.background = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    panel.background = element_blank(),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    plot.title = element_text(hjust=0.5)
  ) + labs(title="Response time (secs)",
           x ="Potential Gain ($)", y = "Potential Loss ($)")

ggsave(filename="fig1B.pdf",plot = plot1,width=3.5,height=2.9)
ggsave(filename="fig1C.pdf",plot = plot2,width=3.5,height=2.9)
