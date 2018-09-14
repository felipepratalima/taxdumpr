getOldIdsToNewIdsHashmap <- function(merged.dmp) {
  oldIdsToNewIdsHashmap <- merged.dmp %$%
    hashmap::hashmap(oldTaxId, newTaxId)

  return(oldIdsToNewIdsHashmap)
}
