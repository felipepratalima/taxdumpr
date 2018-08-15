loadNodes <- function(nodes.dmp.location = "./nodes.dmp") {
  nodes.dmp <- read.table(nodes.dmp.location, header = F, sep = "|", strip.white = T, fill = T, stringsAsFactors = F)
  nodes.dmp <- nodes.dmp[,1:3]
  names(nodes.dmp) <- c("id", "parentId", "rank")
  ## update
  nodes.dmp <- subset(nodes.dmp, id != parentId)
  ## --

  return(nodes.dmp)
}
