library(taxdumpr)


context("Functions to load the taxdump files")


test_that("loadNames is a function to load names.dmp content into a data frame, with the id, name, nameClass of the names", {
  names.dmp <- loadNames("~/taxdump/names.dmp")

  ## Should return a data frame with 3 columns (id, parentId, rank)
  expect_equal(ncol(names.dmp), 3)
  expect_equal(names(names.dmp), c("id", "name", "nameClass"))

  ## Test one name
  selectedNames <- names.dmp[names.dmp$id == 1094,]
  expect_equal(nrow(selectedNames), 3)
  expect_equal(selectedNames$id, c(1094, 1094, 1094))
  expect_equal(selectedNames$name, c("Chlorobium phaeovibrioides", "Chlorobium phaeovibrioides Pfennig 1968 (Approved Lists 1980) emend. Imhoff 2003", "DSM 269"))
  expect_equal(selectedNames$nameClass, c("scientific name", "authority", "type material"))
})


test_that("loadNodes is a function to load nodes.dmp content into a data frame, with the ids, parent ids and ranks of the nodes", {
  nodes.dmp <- loadNodes("~/taxdump/nodes.dmp")

  ## Should return a data frame with 3 columns (id, parentId, rank)
  expect_equal(ncol(nodes.dmp), 3)
  expect_equal(names(nodes.dmp), c("id", "parentId", "rank"))

  ## Test one node
  selectedNode <- nodes.dmp[nodes.dmp$id == 1094,]
  expect_equal(selectedNode$id, 1094)
  expect_equal(selectedNode$parentId, 1091)
  expect_equal(selectedNode$rank, "species")
})

test_that("loadMerged is a function to load merged.dmp content into a data frame, with the old taxonomy id and new taxonomy id of the nodes", {
  merged.dmp <- loadMerged("~/taxdump/merged.dmp")

  ## Should return a data frame with 3 columns (id, parentId, rank)
  expect_equal(ncol(merged.dmp), 2)
  expect_equal(names(merged.dmp), c("oldTaxId", "newTaxId"))

  ## Test one node
  selectedNode <- merged.dmp[merged.dmp$oldTaxId == 319938,]
  expect_equal(selectedNode$oldTaxId, 319938)
  expect_equal(selectedNode$newTaxId, 288004)
})
