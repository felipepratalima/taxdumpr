getIdsToParentIdsHashmap <- function(nodes.dmp) {
  idsToParentIdsHashmap <- hashmap::hashmap(nodes.dmp$id, nodes.dmp$parentId)

  return(idsToParentIdsHashmap)
}
