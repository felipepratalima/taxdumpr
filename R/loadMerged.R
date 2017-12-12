## TODO: write tests
loadMerged <- function(merged.dmp.location = "./merged.dmp") {
  merged.dmp <- read.table(merged.dmp.location, header = F, sep = "|", strip.white = T, fill = T, stringsAsFactors = F)
  merged.dmp <- merged.dmp[,1:2]
  names(merged.dmp) <- c("oldTaxId", "newTaxId")
  return(merged.dmp)
}
