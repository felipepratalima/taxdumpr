getIdsToRanksHashmap <- function(nodes.dmp) {
  idsToRanksHashmap <- hashmap::hashmap(nodes.dmp$id, nodes.dmp$rank)

  return(idsToRanksHashmap)
}
