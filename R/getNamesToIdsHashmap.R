getNamesToIdsHashmap <- function(names.dmp) {
  duplicatedIndexes <- which(duplicated(names.dmp$name))
  uniqueNamesDmp <- names.dmp[-duplicatedIndexes,]

  namesToIdsHashmap <- uniqueNamesDmp %>%
    dplyr::filter(nameClass %in% c("authority", "type material", "misnomer") == FALSE) %$%
    hashmap::hashmap(name, id)

  return(namesToIdsHashmap)
}
