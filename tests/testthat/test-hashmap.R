library(taxdumpr)


context("Functions to get the hashmaps")


names.dmp <- loadNames("~/taxdump/names.dmp")

scientificNames.names.dmp <- dplyr::filter(names.dmp, nameClass == "scientific name")

duplicatedIndexes <- which(duplicated(names.dmp$name))
uniqueNamesDmp <- names.dmp[-duplicatedIndexes,]
allNames.names.dmp <- dplyr::filter(uniqueNamesDmp, nameClass %in% c("authority", "type material", "misnomer") == FALSE)

nodes.dmp <- loadNodes("~/taxdump/nodes.dmp")


## getIdsToNamesHashmap
test_that("getIdsToNamesHashmap is a function which receives a names.dmp data frame and return a hashmap, where the key is the taxonomy id and the value is the taxonomy name", {
  ## Should return a hashmap [taxonomy id => taxonomy name]
  idsToNamesHashmap <- getIdsToNamesHashmap(names.dmp)

  expect_equal(idsToNamesHashmap$size(), nrow(scientificNames.names.dmp))
  expect_equal(idsToNamesHashmap$find(1091), "Chlorobium")
  expect_equal(idsToNamesHashmap$find(1094), "Chlorobium phaeovibrioides")
  expect_equal(idsToNamesHashmap$find(290318), "Chlorobium phaeovibrioides DSM 265")
})


## getNamesToIdsHashmap
test_that("getNamesToIdsHashmap is a function which receives a names.dmp data frame and return a hashmap, where the key is the taxonomy name and the value is the taxonomy id", {
  ## Should return a hashmap [taxonomy id => taxonomy name]
  namesToIdsHashmap <- getNamesToIdsHashmap(names.dmp)

  expect_equal(namesToIdsHashmap$size(), length(unique(allNames.names.dmp$name)))
  expect_equal(namesToIdsHashmap$find("Chlorobium"), 1091)
  expect_equal(namesToIdsHashmap$find("Chlorobium phaeovibrioides"), 1094)
  expect_equal(namesToIdsHashmap$find("Chlorobium phaeovibrioides DSM 265"), 290318)
})


## getIdsToParentIdsHashmap
test_that("getIdsToParentIdsHashmap is a function which receives a nodes.dmp data frame and return a hashmap, where the key is the taxonomy id and the value is its parent taxonomy id", {
  ## Should return a hashmap [taxonomy id => parent taxonomy id]
  idsToParentIdsHashmap <- getIdsToParentIdsHashmap(nodes.dmp)

  expect_equal(idsToParentIdsHashmap$size(), nrow(nodes.dmp))
  expect_equal(idsToParentIdsHashmap$find(1094), 1091)
  expect_equal(idsToParentIdsHashmap$find(290318), 1094)
})


# idToRankHashmap <- hashmap(nodes.dmp$id, nodes.dmp$rank)
test_that("getIdsToParentIdsHashmap is a function which receives a nodes.dmp data frame and return a hashmap, where the key is the taxonomy id and the value is its rank", {
  ## Should return a hashmap [taxonomy id => parent taxonomy id]
  idsToRanksHashmap <- getIdsToRanksHashmap(nodes.dmp)

  expect_equal(idsToRanksHashmap$size(), nrow(nodes.dmp))
  expect_equal(idsToRanksHashmap$find(1091), "genus")
  expect_equal(idsToRanksHashmap$find(1094), "species")
  expect_equal(idsToRanksHashmap$find(290318), "no rank")
})
