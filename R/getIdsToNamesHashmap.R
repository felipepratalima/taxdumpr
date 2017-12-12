getIdsToNamesHashmap <- function(names.dmp) {
  scientificaNames.names.dmp <- names.dmp %>%
    dplyr::filter(nameClass == "scientific name")

  idToNamesHashmap <- scientificaNames.names.dmp  %$%
    hashmap::hashmap(id, name)

  return(idToNamesHashmap)
}
