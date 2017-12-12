loadNames <- function(names.dmp.location = "./names.dmp") {
  names.dmp <- read.table(names.dmp.location, header = F, sep = "|", strip.white = T, fill = T, stringsAsFactors = F, quote = "")
  names.dmp <- names.dmp[,c(1,2,4)]
  names(names.dmp) <- c("id", "name", "nameClass")
  return(names.dmp)
}
