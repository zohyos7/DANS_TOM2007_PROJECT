rm(list=ls())

file_list = dir('.')

for (i in 1:length(file_list)){
  id = substr(file_list[i], 1, 6)
  run = substr(file_list[i], 34, 35)
  tmp = read.table(file_list[i], header = T, sep = "\t")
  accept = subset(tmp, respcat == 1)
  reject = subset(tmp, respcat == 0)
  accept$new_onset = accept$onset + accept$response_time
  reject$new_onset = reject$onset + reject$response_time
  
  write.table(accept, file=paste(id,'_accept_run-0',run,'.tsv', sep = ""), quote=FALSE, sep='\t', col.names = TRUE)
  write.table(reject, file=paste(id,'_reject_run-0',run,'.tsv', sep = ""), quote=FALSE, sep='\t', col.names=TRUE)
  }


