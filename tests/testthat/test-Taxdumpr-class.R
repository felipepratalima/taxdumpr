library(taxdumpr)


context("Taxdumpr class")


names.dmp <- loadNames("~/taxdump/names.dmp")

scientificNames.names.dmp <- dplyr::filter(names.dmp, nameClass == "scientific name")

duplicatedIndexes <- which(duplicated(names.dmp$name))
uniqueNamesDmp <- names.dmp[-duplicatedIndexes,]
allNames.names.dmp <- dplyr::filter(uniqueNamesDmp, nameClass %in% c("authority", "type material", "misnomer") == FALSE)


nodes.dmp <- loadNodes("~/taxdump/nodes.dmp")


taxdumpr <- Taxdumpr(nodesDmpLocation = "~/taxdump/nodes.dmp", namesDmpLocation = "~/taxdump/names.dmp")


test_that("A taxdumpr class should have .namesDmpLocation, .nodesDmpLocation and extracted hashmaps from them", {
  expect_equal(taxdumpr@.namesDmpLocation, "~/taxdump/names.dmp")
  expect_equal(taxdumpr@.nodesDmpLocation, "~/taxdump/nodes.dmp")

  expect_equal(taxdumpr@.idsToNames$size(), nrow(scientificNames.names.dmp))
  expect_equal(taxdumpr@.namesToIds$size(), length(unique(allNames.names.dmp$name)))
  expect_equal(taxdumpr@.idsToRanks$size(), nrow(nodes.dmp))
  expect_equal(taxdumpr@.idsToParentIds$size(), nrow(nodes.dmp))
  expect_equal(taxdumpr@.STANDARD_RANKS, c("superkingdom", "phylum" , "class", "order", "family", "genus", "species"))
})


test_that("The getTaxonomyIdsByNames function should receive taxonomy name(s) and return taxonomy id(s)", {
  ## NA
  expect_equal(getTaxonomyIdsByNames(taxdumpr, NA), NA_integer_)

  ## Inexistent name
  expect_equal(getTaxonomyIdsByNames(taxdumpr, "An inexistent taxonomy name"), NA_integer_)

  ## Scientific names
  expect_equal(getTaxonomyIdsByNames(taxdumpr, "Corynebacterium"), 1716)
  expect_equal(getTaxonomyIdsByNames(taxdumpr, "Corynebacterium variabile"), 1727)

  ## Synonyms
  expect_equal(getTaxonomyIdsByNames(taxdumpr, "Caseobacter"), 1716)
  expect_equal(getTaxonomyIdsByNames(taxdumpr, "Caseobacter polymorphus"), 1727)

  ## Lists
  expect_equal(getTaxonomyIdsByNames(taxdumpr, c("Corynebacterium", NA)), c(1716, NA_integer_))
  expect_equal(getTaxonomyIdsByNames(taxdumpr, c("Corynebacterium", "An inexistent taxonomy name")), c(1716, NA_integer_))

  expect_equal(getTaxonomyIdsByNames(taxdumpr, c("Corynebacterium", "Corynebacterium variabile")), c(1716, 1727))
  expect_equal(getTaxonomyIdsByNames(taxdumpr, c("Caseobacter", "Caseobacter polymorphus")), c(1716, 1727))

  expect_equal(getTaxonomyIdsByNames(taxdumpr, c("Corynebacterium", "Caseobacter")), c(1716, 1716))
  expect_equal(getTaxonomyIdsByNames(taxdumpr, c("Corynebacterium variabile", "Caseobacter polymorphus")), c(1727, 1727))
})


test_that("The getScientificNamesByIds function should receive taxonomy id(s) and return the scientific name(s)", {
  ## NA
  expect_equal(getScientificNamesByIds(taxdumpr, NA), NA_character_)

  ## Inexistent id
  expect_equal(getScientificNamesByIds(taxdumpr, 9876543210123456789), NA_character_)

  ## Valid ids
  expect_equal(getScientificNamesByIds(taxdumpr, 1716), "Corynebacterium")
  expect_equal(getScientificNamesByIds(taxdumpr, 1727), "Corynebacterium variabile")

  ## Lists
  expect_equal(getScientificNamesByIds(taxdumpr, c(1716, NA)), c("Corynebacterium", NA_character_))
  expect_equal(getScientificNamesByIds(taxdumpr, c(1716, 9876543210123456789)), c("Corynebacterium", NA_character_))
  expect_equal(getScientificNamesByIds(taxdumpr, c(1716, 1727)), c("Corynebacterium", "Corynebacterium variabile"))
})


test_that("The getScientificNamesByNames function should receive taxonomy name(s) and return the scientific name(s)", {
  ## NA
  expect_equal(getScientificNamesByNames(taxdumpr, NA), NA_character_)

  ## Inexistent name
  expect_equal(getScientificNamesByNames(taxdumpr, "An inexistent taxonomy name"), NA_character_)

  ## Scientific names
  expect_equal(getScientificNamesByNames(taxdumpr, "Corynebacterium"), "Corynebacterium")
  expect_equal(getScientificNamesByNames(taxdumpr, "Corynebacterium variabile"), "Corynebacterium variabile")

  ## Synonyms
  expect_equal(getScientificNamesByNames(taxdumpr, "Caseobacter"), "Corynebacterium")
  expect_equal(getScientificNamesByNames(taxdumpr, "Caseobacter polymorphus"), "Corynebacterium variabile")

  ## Lists
  expect_equal(getScientificNamesByNames(taxdumpr, c("Corynebacterium", NA)), c("Corynebacterium", NA_character_))
  expect_equal(getScientificNamesByNames(taxdumpr, c("Corynebacterium", "An inexistent taxonomy name")), c("Corynebacterium", NA_character_))

  expect_equal(getScientificNamesByNames(taxdumpr, c("Corynebacterium", "Corynebacterium variabile")), c("Corynebacterium", "Corynebacterium variabile"))
  expect_equal(getScientificNamesByNames(taxdumpr, c("Caseobacter", "Caseobacter polymorphus")), c("Corynebacterium", "Corynebacterium variabile"))

  expect_equal(getScientificNamesByNames(taxdumpr, c("Corynebacterium", "Caseobacter")), c("Corynebacterium", "Corynebacterium"))
  expect_equal(getScientificNamesByNames(taxdumpr, c("Corynebacterium variabile", "Caseobacter polymorphus")), c("Corynebacterium variabile", "Corynebacterium variabile"))
})


test_that("The getTaxonomyRanksByIds function should receive taxonomy id(s) and return ranks(s)", {
  ## NA
  expect_equal(getTaxonomyRanksByIds(taxdumpr, NA), NA_character_)

  ## Inexistent id
  expect_equal(getTaxonomyRanksByIds(taxdumpr, 9876543210123456789), NA_character_)

  ## Valid ids
  expect_equal(getTaxonomyRanksByIds(taxdumpr, 1716), "genus")
  expect_equal(getTaxonomyRanksByIds(taxdumpr, 1727), "species")

  ## Lists
  expect_equal(getTaxonomyRanksByIds(taxdumpr, c(1716, NA)), c("genus", NA_character_))
  expect_equal(getTaxonomyRanksByIds(taxdumpr, c(1716, 9876543210123456789)), c("genus", NA_character_))
  expect_equal(getTaxonomyRanksByIds(taxdumpr, c(1716, 1727)), c("genus", "species"))
})


test_that("The getTaxonomyRanksByNames function should receive taxonomy name(s) and return ranks(s)", {
  ## NA
  expect_equal(getTaxonomyRanksByNames(taxdumpr, NA), NA_character_)

  ## Inexistent name
  expect_equal(getTaxonomyRanksByNames(taxdumpr, "An inexistent taxonomy name"), NA_character_)

  ## Valid names
  expect_equal(getTaxonomyRanksByNames(taxdumpr, "Corynebacterium"), "genus")
  expect_equal(getTaxonomyRanksByNames(taxdumpr, "Corynebacterium variabile"), "species")
  expect_equal(getTaxonomyRanksByNames(taxdumpr, "Caseobacter"), "genus")
  expect_equal(getTaxonomyRanksByNames(taxdumpr, "Caseobacter polymorphus"), "species")

  ## Lists
  expect_equal(getTaxonomyRanksByNames(taxdumpr, c("Corynebacterium", NA)), c("genus", NA_character_))
  expect_equal(getTaxonomyRanksByNames(taxdumpr, c("Corynebacterium", "An inexistent taxonomy name")), c("genus", NA_character_))
  expect_equal(getTaxonomyRanksByNames(taxdumpr, c("Corynebacterium", "Corynebacterium variabile", "Caseobacter", "Caseobacter polymorphus")), c("genus", "species", "genus", "species"))
})


test_that("The getParentTaxonomyIdsByIds function should receive taxonomy id(s) and return parent id(s)", {
  ## NA
  expect_equal(getParentTaxonomyIdsByIds(taxdumpr, NA), NA_integer_)

  ## Inexistent id
  expect_equal(getParentTaxonomyIdsByIds(taxdumpr, 9876543210123456789), NA_integer_)

  ## Valid ids
  expect_equal(getParentTaxonomyIdsByIds(taxdumpr, 1716), 1653)
  expect_equal(getParentTaxonomyIdsByIds(taxdumpr, 1727), 1716)

  ## Lists
  expect_equal(getParentTaxonomyIdsByIds(taxdumpr, c(1716, NA)), c(1653, NA_integer_))
  expect_equal(getParentTaxonomyIdsByIds(taxdumpr, c(1716, 9876543210123456789)), c(1653, NA_integer_))
  expect_equal(getParentTaxonomyIdsByIds(taxdumpr, c(1716, 1727)), c(1653, 1716))
})


test_that("The getParentTaxonomyIdsByNames function should receive taxonomy name(s) and return parent taxonomy id(s)", {
  ## NA
  expect_equal(getParentTaxonomyIdsByNames(taxdumpr, NA), NA_integer_)

  ## Inexistent id
  expect_equal(getParentTaxonomyIdsByNames(taxdumpr, "An inexistent taxonomy name"), NA_integer_)

  ## Valid ids
  expect_equal(getParentTaxonomyIdsByNames(taxdumpr, "Corynebacterium"), 1653)
  expect_equal(getParentTaxonomyIdsByNames(taxdumpr, "Corynebacterium variabile"), 1716)

  ## Lists
  expect_equal(getParentTaxonomyIdsByNames(taxdumpr, c("Corynebacterium", NA)), c(1653, NA_integer_))
  expect_equal(getParentTaxonomyIdsByNames(taxdumpr, c("Corynebacterium", "An inexistent taxonomy name")), c(1653, NA_integer_))
  expect_equal(getParentTaxonomyIdsByNames(taxdumpr, c("Corynebacterium", "Corynebacterium variabile")), c(1653, 1716))
})


test_that("The getParentScientificNamesByIds function should receive taxonomy id(s) and return parent scientific name(s)", {
  ## NA
  expect_equal(getParentScientificNamesByIds(taxdumpr, NA), NA_character_)

  ## Inexistent id
  expect_equal(getParentScientificNamesByIds(taxdumpr, 9876543210123456789), NA_character_)

  ## Valid ids
  expect_equal(getParentScientificNamesByIds(taxdumpr, 1716), "Corynebacteriaceae")
  expect_equal(getParentScientificNamesByIds(taxdumpr, 1727), "Corynebacterium")

  ## Lists
  expect_equal(getParentScientificNamesByIds(taxdumpr, c(1716, NA)), c("Corynebacteriaceae", NA_character_))
  expect_equal(getParentScientificNamesByIds(taxdumpr, c(1716, 9876543210123456789)), c("Corynebacteriaceae", NA_character_))
  expect_equal(getParentScientificNamesByIds(taxdumpr, c(1716, 1727)), c("Corynebacteriaceae", "Corynebacterium"))
})


test_that("The getParentScientificNamesByNames function should receive taxonomy name(s) and return parent scientific name(s)", {
  ## NA
  expect_equal(getParentScientificNamesByNames(taxdumpr, NA), NA_character_)

  ## Inexistent id
  expect_equal(getParentScientificNamesByNames(taxdumpr, "An inexistent taxonomy name"), NA_character_)

  ## Valid ids
  expect_equal(getParentScientificNamesByNames(taxdumpr, "Corynebacterium"), "Corynebacteriaceae")
  expect_equal(getParentScientificNamesByNames(taxdumpr, "Corynebacterium variabile"), "Corynebacterium")

  ## Lists
  expect_equal(getParentScientificNamesByNames(taxdumpr, c("Corynebacterium", NA)), c("Corynebacteriaceae", NA_character_))
  expect_equal(getParentScientificNamesByNames(taxdumpr, c("Corynebacterium", "An inexistent taxonomy name")), c("Corynebacteriaceae", NA_character_))
  expect_equal(getParentScientificNamesByNames(taxdumpr, c("Corynebacterium", "Corynebacterium variabile")), c("Corynebacteriaceae", "Corynebacterium"))
})


test_that("The getStandardTaxonomyIdsByIds function should receive taxonomy id(s) of taxon(s) in non-standard level and return correspondent taxonomy id(s) in standard level", {
  ## NA
  expect_equal(getStandardTaxonomyIdsByIds(taxdumpr, NA), NA_integer_)

  ## Inexistent id
  expect_equal(getStandardTaxonomyIdsByIds(taxdumpr, 9876543210123456789), NA_integer_)

  ## Valid ids (non standard)
  expect_equal(getStandardTaxonomyIdsByIds(taxdumpr, 290318), 1094)
  expect_equal(getStandardTaxonomyIdsByIds(taxdumpr, 274493), 191412)
  expect_equal(getStandardTaxonomyIdsByIds(taxdumpr, 1783270), 2)

  ## Valid ids (standard)
  expect_equal(getStandardTaxonomyIdsByIds(taxdumpr, 1094), 1094)
  expect_equal(getStandardTaxonomyIdsByIds(taxdumpr, 191412), 191412)
  expect_equal(getStandardTaxonomyIdsByIds(taxdumpr, 2), 2)

  ## Lists
  expect_equal(getStandardTaxonomyIdsByIds(taxdumpr, c(NA, NA)), c(NA_integer_, NA_integer_))
  expect_equal(getStandardTaxonomyIdsByIds(taxdumpr, c(290318, 274493, 1783270)), c(1094, 191412, 2))
  expect_equal(getStandardTaxonomyIdsByIds(taxdumpr, c(1094, 191412, 2)), c(1094, 191412, 2))
  expect_equal(getStandardTaxonomyIdsByIds(taxdumpr, c(NA, NA, 290318, 274493, 1783270, 1094, 191412, 2)), c(NA_integer_, NA_integer_, 1094, 191412, 2, 1094, 191412, 2))

  ## Lists (repeated)
  expect_equal(getStandardTaxonomyIdsByIds(taxdumpr, c(290318, 290318, 290318, 274493, 1783270, 290318)), c(1094, 1094, 1094, 191412, 2, 1094))
})


test_that("The getStandardTaxonomyIdsByNames function should receive taxonomy name(s) in non-standard level and return correspondent taxonomy id(s) in standard level", {
  ## NA
  expect_equal(getStandardTaxonomyIdsByNames(taxdumpr, NA), NA_integer_)

  ## Inexistent id
  expect_equal(getStandardTaxonomyIdsByNames(taxdumpr, "An inexistent taxonomy name"), NA_integer_)

  ## Valid ids (non standard)
  expect_equal(getStandardTaxonomyIdsByNames(taxdumpr, "Chlorobium phaeovibrioides DSM 265"), 1094)
  expect_equal(getStandardTaxonomyIdsByNames(taxdumpr, "Chlorobium/Pelodictyon group"), 191412)
  expect_equal(getStandardTaxonomyIdsByNames(taxdumpr, "FCB group"), 2)

  ## Valid ids (standard)
  expect_equal(getStandardTaxonomyIdsByNames(taxdumpr, "Chlorobium phaeovibrioides"), 1094)
  expect_equal(getStandardTaxonomyIdsByNames(taxdumpr, "Chlorobiaceae"), 191412)
  expect_equal(getStandardTaxonomyIdsByNames(taxdumpr, "Bacteria"), 2)

  ## Lists
  expect_equal(getStandardTaxonomyIdsByNames(taxdumpr, c(NA, NA)), c(NA_integer_, NA_integer_))
  expect_equal(getStandardTaxonomyIdsByNames(taxdumpr, c("Chlorobium phaeovibrioides DSM 265", "Chlorobium/Pelodictyon group", "FCB group")), c(1094, 191412, 2))
  expect_equal(getStandardTaxonomyIdsByNames(taxdumpr, c("Chlorobium phaeovibrioides", "Chlorobiaceae", "Bacteria")), c(1094, 191412, 2))

  expect_equal(
    getStandardTaxonomyIdsByNames(taxdumpr,
      c(NA, NA, "Chlorobium phaeovibrioides DSM 265", "Chlorobium/Pelodictyon group", "FCB group", "Chlorobium phaeovibrioides", "Chlorobiaceae", "Bacteria")),
      c(NA_integer_, NA_integer_, 1094, 191412, 2, 1094, 191412, 2))

  ## Lists (repeated)
  expect_equal(
    getStandardTaxonomyIdsByNames(taxdumpr,
      c("Chlorobium phaeovibrioides DSM 265", "Chlorobium phaeovibrioides DSM 265", "Chlorobium phaeovibrioides DSM 265", "Chlorobium/Pelodictyon group", "FCB group", "Chlorobium phaeovibrioides DSM 265")),
      c(1094, 1094, 1094, 191412, 2, 1094))
})


test_that("The getStandardScientificNamesByNames function should receive taxonomy name(s) in non-standard level and return correspondent taxonomy name(s) in standard level", {
  ## NA
  expect_equal(getStandardScientificNamesByNames(taxdumpr, NA), NA_character_)

  ## Inexistent id
  expect_equal(getStandardScientificNamesByNames(taxdumpr, "An inexistent taxonomy name"), NA_character_)

  ## Valid ids (non standard)
  expect_equal(getStandardScientificNamesByNames(taxdumpr, "Chlorobium phaeovibrioides DSM 265"), "Chlorobium phaeovibrioides")
  expect_equal(getStandardScientificNamesByNames(taxdumpr, "Chlorobium/Pelodictyon group"), "Chlorobiaceae")
  expect_equal(getStandardScientificNamesByNames(taxdumpr, "FCB group"), "Bacteria")

  ## Valid ids (standard)
  expect_equal(getStandardScientificNamesByNames(taxdumpr, "Chlorobium phaeovibrioides"), "Chlorobium phaeovibrioides")
  expect_equal(getStandardScientificNamesByNames(taxdumpr, "Chlorobiaceae"), "Chlorobiaceae")
  expect_equal(getStandardScientificNamesByNames(taxdumpr, "Bacteria"), "Bacteria")

  ## Lists
  expect_equal(getStandardScientificNamesByNames(taxdumpr, c(NA, NA)), c(NA_character_, NA_character_))
  expect_equal(getStandardScientificNamesByNames(taxdumpr, c("Chlorobium phaeovibrioides DSM 265", "Chlorobium/Pelodictyon group", "FCB group")), c("Chlorobium phaeovibrioides", "Chlorobiaceae", "Bacteria"))
  expect_equal(getStandardScientificNamesByNames(taxdumpr, c("Chlorobium phaeovibrioides", "Chlorobiaceae", "Bacteria")), c("Chlorobium phaeovibrioides", "Chlorobiaceae", "Bacteria"))

  expect_equal(
    getStandardScientificNamesByNames(taxdumpr,
                                  c(NA, NA, "Chlorobium phaeovibrioides DSM 265", "Chlorobium/Pelodictyon group", "FCB group", "Chlorobium phaeovibrioides", "Chlorobiaceae", "Bacteria")),
    c(NA_character_, NA_character_, "Chlorobium phaeovibrioides", "Chlorobiaceae", "Bacteria", "Chlorobium phaeovibrioides", "Chlorobiaceae", "Bacteria"))

  ## Lists (repeated)
  expect_equal(
    getStandardScientificNamesByNames(taxdumpr,
                                  c("Chlorobium phaeovibrioides DSM 265", "Chlorobium phaeovibrioides DSM 265", "Chlorobium phaeovibrioides DSM 265", "Chlorobium/Pelodictyon group", "FCB group", "Chlorobium phaeovibrioides DSM 265")),
    c("Chlorobium phaeovibrioides", "Chlorobium phaeovibrioides", "Chlorobium phaeovibrioides", "Chlorobiaceae", "Bacteria", "Chlorobium phaeovibrioides"))
})

test_that("The getLineageIdsByIds function should receive taxonomy id(s) and return complete taxonomy", {
  ## NA
  lineage <- getLineageIdsByIds(taxdumpr, NA)
  expect_equal(nrow(lineage), 0)

  ## Inexistent id
  lineage <- getLineageIdsByIds(taxdumpr, 9876543210123456789)
  expect_equal(nrow(lineage), 1)
  expect_equal(lineage$lineageId, 9876543210123456789)

  ## Valid id
  lineage <- getLineageIdsByIds(taxdumpr, 290318)
  expect_equal(nrow(lineage), 11)
  expect_equal(lineage$lineageId, c(2,1783270,68336,1090,191410,191411,191412,274493,1091,1094,290318))

  ## Valid id (2)
  lineage <- getLineageIdsByIds(taxdumpr, c(2, 290318, 1094))
  expect_equal(nrow(lineage), 22)
  expect_equal(lineage$lineageId, c(2, 2,1783270,68336,1090,191410,191411,191412,274493,1091,1094,290318, 2,1783270,68336,1090,191410,191411,191412,274493,1091,1094))

  ## Valid id (duplicated)
  lineage <- getLineageIdsByIds(taxdumpr, c(290318, 290318))
  expect_equal(nrow(lineage), 11)
  expect_equal(lineage$lineageId, c(2,1783270,68336,1090,191410,191411,191412,274493,1091,1094,290318))

  ## Inexistent and Valid id
  lineage <- getLineageIdsByIds(taxdumpr, c(9876543210123456789, 290318))
  expect_equal(nrow(lineage), 12)
  expect_equal(lineage$taxonomyId, c(9876543210123456789, replicate(11, 290318)))
  expect_equal(lineage$lineageId, c(9876543210123456789, 2,1783270,68336,1090,191410,191411,191412,274493,1091,1094,290318))

  ## NA and Valid id
  lineage <- getLineageIdsByIds(taxdumpr, c(NA, 290318))
  expect_equal(nrow(lineage), 11)
  expect_equal(lineage$taxonomyId, c(replicate(11, 290318)))
  expect_equal(lineage$lineageId, c(2,1783270,68336,1090,191410,191411,191412,274493,1091,1094,290318))

  ## Inexistent, NA and Valid id
  lineage <- getLineageIdsByIds(taxdumpr, c(9876543210123456789, 290318))
  expect_equal(nrow(lineage), 12)
  expect_equal(lineage$taxonomyId, c(9876543210123456789, replicate(11, 290318)))
  expect_equal(lineage$lineageId, c(9876543210123456789, 2,1783270,68336,1090,191410,191411,191412,274493,1091,1094,290318))

  ## Inexistent, NA and Valid id (duplicated)
  lineage <- getLineageIdsByIds(taxdumpr, c(NA, 9876543210123456789, 290318, 290318))
  expect_equal(nrow(lineage), 12)
  expect_equal(lineage$taxonomyId, c(9876543210123456789, replicate(11, 290318)))
  expect_equal(lineage$lineageId, c(9876543210123456789, 2,1783270,68336,1090,191410,191411,191412,274493,1091,1094,290318))
})


test_that("The getStandardLineageIdsByIds function should receive taxonomy id(s) and return standard taxonomy", {
  ## NA
  lineage <- getStandardLineageIdsByIds(taxdumpr, NA)
  expect_equal(nrow(lineage), 0)

  ## Inexistent id
  lineage <- getStandardLineageIdsByIds(taxdumpr, 9876543210123456789)
  expect_equal(nrow(lineage), 1)
  expect_equal(lineage$lineageId, 9876543210123456789)

  ## Valid id (subspecies)
  lineage <- getStandardLineageIdsByIds(taxdumpr, 290318)
  expect_equal(nrow(lineage), 7)
  expect_equal(lineage$lineageId, c(2,1090,191410,191411,191412,1091,1094))

  ## Valid id (species)
  lineage <- getStandardLineageIdsByIds(taxdumpr, 1094)
  expect_equal(nrow(lineage), 7)
  expect_equal(lineage$lineageId, c(2,1090,191410,191411,191412,1091,1094))

  ## Valid id (genus)
  lineage <- getStandardLineageIdsByIds(taxdumpr, 1091)
  expect_equal(nrow(lineage), 6)
  expect_equal(lineage$lineageId, c(2,1090,191410,191411,191412,1091))

  ## Valid id (2)
  lineage <- getStandardLineageIdsByIds(taxdumpr, c(2, 290318, 1094))
  expect_equal(nrow(lineage), 15)
  expect_equal(lineage$lineageId, c(2, 2,1090,191410,191411,191412,1091,1094, 2,1090,191410,191411,191412,1091,1094))

  # ## Valid id (duplicated)
  lineage <- getStandardLineageIdsByIds(taxdumpr, c(290318, 290318))
  expect_equal(nrow(lineage), 7)
  expect_equal(lineage$lineageId, c(2,1090,191410,191411,191412,1091,1094))
  #
  # ## Inexistent and Valid id
  # lineage <- getLineageIdsByIds(taxdumpr, c(9876543210123456789, 290318))
  # expect_equal(nrow(lineage), 12)
  # expect_equal(lineage$taxonomyId, c(9876543210123456789, replicate(11, 290318)))
  # expect_equal(lineage$lineageId, c(9876543210123456789, 2,1783270,68336,1090,191410,191411,191412,274493,1091,1094,290318))
  #
  # ## NA and Valid id
  # lineage <- getLineageIdsByIds(taxdumpr, c(NA, 290318))
  # expect_equal(nrow(lineage), 11)
  # expect_equal(lineage$taxonomyId, c(replicate(11, 290318)))
  # expect_equal(lineage$lineageId, c(2,1783270,68336,1090,191410,191411,191412,274493,1091,1094,290318))
  #
  # ## Inexistent, NA and Valid id
  # lineage <- getLineageIdsByIds(taxdumpr, c(9876543210123456789, 290318))
  # expect_equal(nrow(lineage), 12)
  # expect_equal(lineage$taxonomyId, c(9876543210123456789, replicate(11, 290318)))
  # expect_equal(lineage$lineageId, c(9876543210123456789, 2,1783270,68336,1090,191410,191411,191412,274493,1091,1094,290318))
  #
  # ## Inexistent, NA and Valid id (duplicated)
  # lineage <- getLineageIdsByIds(taxdumpr, c(NA, 9876543210123456789, 290318, 290318))
  # expect_equal(nrow(lineage), 12)
  # expect_equal(lineage$taxonomyId, c(9876543210123456789, replicate(11, 290318)))
  # expect_equal(lineage$lineageId, c(9876543210123456789, 2,1783270,68336,1090,191410,191411,191412,274493,1091,1094,290318))
})

test_that("The getStandardLineageIdsByIdsAsDataFrame function should receive taxonomy id(s) and return standard taxonomy as DF = [taxonomyId, superkingdomId, phylumId, ..., speciesId]", {
  ## NA
  lineage <- getStandardLineageIdsByIdsAsDataFrame(taxdumpr, NA)
  expect_equal(nrow(lineage), 1)
  expect_equal(ncol(lineage), 8)
  expect_equal(colnames(lineage), c("taxonomyId", "superkingdomId", "phylumId", "classId", "orderId", "familyId", "genusId", "speciesId"))
  expect_equal(lineage[1,] %>% as.numeric, c(NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_))

  ## Inexistent id
  lineage <- getStandardLineageIdsByIdsAsDataFrame(taxdumpr, 9876543210123456789)
  expect_equal(nrow(lineage), 1)
  expect_equal(ncol(lineage), 8)
  expect_equal(colnames(lineage), c("taxonomyId", "superkingdomId", "phylumId", "classId", "orderId", "familyId", "genusId", "speciesId"))
  expect_equal(lineage[1,] %>% as.numeric, c(9876543210123456789,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_))

  ## Valid id (subspecies)
  lineage <- getStandardLineageIdsByIdsAsDataFrame(taxdumpr, 290318)
  expect_equal(nrow(lineage), 1)
  expect_equal(ncol(lineage), 8)
  expect_equal(colnames(lineage), c("taxonomyId", "superkingdomId", "phylumId", "classId", "orderId", "familyId", "genusId", "speciesId"))
  expect_equal(lineage[1,] %>% as.numeric, c(290318,2,1090,191410,191411,191412,1091,1094))

  ## Valid id (species)
  lineage <- getStandardLineageIdsByIdsAsDataFrame(taxdumpr, 1094)
  expect_equal(nrow(lineage), 1)
  expect_equal(ncol(lineage), 8)
  expect_equal(colnames(lineage), c("taxonomyId", "superkingdomId", "phylumId", "classId", "orderId", "familyId", "genusId", "speciesId"))
  expect_equal(lineage[1,] %>% as.numeric, c(1094,2,1090,191410,191411,191412,1091,1094))

  ## Valid id (incomplete taxonomy species)
  lineage <- getStandardLineageIdsByIdsAsDataFrame(taxdumpr, 460513)
  expect_equal(nrow(lineage), 1)
  expect_equal(ncol(lineage), 8)
  expect_equal(colnames(lineage), c("taxonomyId", "superkingdomId", "phylumId", "classId", "orderId", "familyId", "genusId", "speciesId"))
  expect_equal(lineage[1,] %>% as.numeric, c(460513,2,1224,1807140,225057,225058,NA_integer_,460513))

  ## Valid id (genus)
  lineage <- getStandardLineageIdsByIdsAsDataFrame(taxdumpr, 1091)
  expect_equal(nrow(lineage), 1)
  expect_equal(ncol(lineage), 8)
  expect_equal(colnames(lineage), c("taxonomyId", "superkingdomId", "phylumId", "classId", "orderId", "familyId", "genusId", "speciesId"))
  expect_equal(lineage[1,] %>% as.numeric, c(1091,2,1090,191410,191411,191412,1091,NA_integer_))

  ## Valid id (2)
  lineage <- getStandardLineageIdsByIdsAsDataFrame(taxdumpr, c(2, 290318, 1094))
  expect_equal(nrow(lineage), 3)
  expect_equal(ncol(lineage), 8)
  expect_equal(colnames(lineage), c("taxonomyId", "superkingdomId", "phylumId", "classId", "orderId", "familyId", "genusId", "speciesId"))
  expect_equal(lineage[1,] %>% as.numeric, c(2,2,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_))
  expect_equal(lineage[2,] %>% as.numeric, c(1094,2,1090,191410,191411,191412,1091,1094))
  expect_equal(lineage[3,] %>% as.numeric, c(290318,2,1090,191410,191411,191412,1091,1094))

  ## Valid ids, NA, and inexistent ids
  lineage <- getStandardLineageIdsByIdsAsDataFrame(taxdumpr, c(2, 290318, NA, 9876543210123456789, 1094))
  expect_equal(nrow(lineage), 5)
  expect_equal(ncol(lineage), 8)
  expect_equal(colnames(lineage), c("taxonomyId", "superkingdomId", "phylumId", "classId", "orderId", "familyId", "genusId", "speciesId"))
  expect_equal(lineage[1,] %>% as.numeric, c(2,2,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_))
  expect_equal(lineage[2,] %>% as.numeric, c(1094,2,1090,191410,191411,191412,1091,1094))
  expect_equal(lineage[3,] %>% as.numeric, c(290318,2,1090,191410,191411,191412,1091,1094))
  expect_equal(lineage[4,] %>% as.numeric, c(9876543210123456789,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_))
  expect_equal(lineage[5,] %>% as.numeric, c(NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_))
})

test_that("The getStandardLineageIdsAndScientificNamesByIdsAsDataFrame function should receive taxonomy id(s) and return standard taxonomy as DF = [taxonomyId, superkingdomId, phylumId, ..., speciesId, superkingdomName, ..., speciesName]", {
  columnsNames <- c("taxonomyId", "superkingdomId", "phylumId", "classId", "orderId", "familyId", "genusId", "speciesId",
                    "taxonomyName", "superkingdomName", "phylumName", "className", "orderName", "familyName", "genusName", "speciesName")

  ## NA
  lineage <- getStandardLineageIdsAndScientificNamesByIdsAsDataFrame(taxdumpr, NA)
  expect_equal(nrow(lineage), 1)
  expect_equal(ncol(lineage), 16)
  expect_equal(colnames(lineage), columnsNames)
  expect_equal(lineage[1,1:8] %>% as.numeric, c(NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_))
  expect_equal(lineage[1,9:16] %>% as.character, c(NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_))

  ## Inexistent id
  lineage <- getStandardLineageIdsAndScientificNamesByIdsAsDataFrame(taxdumpr, 9876543210123456789)
  expect_equal(nrow(lineage), 1)
  expect_equal(ncol(lineage), 16)
  expect_equal(colnames(lineage), columnsNames)
  expect_equal(lineage[1,1:8] %>% as.numeric, c(9876543210123456789,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_))
  expect_equal(lineage[1,9:16] %>% as.character, c(NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_))

  ## Valid id (subspecies)
  lineage <- getStandardLineageIdsAndScientificNamesByIdsAsDataFrame(taxdumpr, 290318)
  expect_equal(nrow(lineage), 1)
  expect_equal(ncol(lineage), 16)
  expect_equal(colnames(lineage), columnsNames)
  expect_equal(lineage[1,1:8] %>% as.numeric, c(290318,2,1090,191410,191411,191412,1091,1094))
  expect_equal(lineage[1,9:16] %>% as.character, c("Chlorobium phaeovibrioides DSM 265", "Bacteria", "Chlorobi", "Chlorobia", "Chlorobiales", "Chlorobiaceae", "Chlorobium", "Chlorobium phaeovibrioides"))

  ## Valid id (species)
  lineage <- getStandardLineageIdsAndScientificNamesByIdsAsDataFrame(taxdumpr, 1094)
  expect_equal(nrow(lineage), 1)
  expect_equal(ncol(lineage), 16)
  expect_equal(colnames(lineage), columnsNames)
  expect_equal(lineage[1,1:8] %>% as.numeric, c(1094, 2,1090,191410,191411,191412,1091,1094))
  expect_equal(lineage[1,9:16] %>% as.character, c("Chlorobium phaeovibrioides", "Bacteria", "Chlorobi", "Chlorobia", "Chlorobiales", "Chlorobiaceae", "Chlorobium", "Chlorobium phaeovibrioides"))

  ## Valid id (incomplete taxonomy species)
  lineage <- getStandardLineageIdsAndScientificNamesByIdsAsDataFrame(taxdumpr, 460513)
  expect_equal(nrow(lineage), 1)
  expect_equal(ncol(lineage), 16)
  expect_equal(colnames(lineage), columnsNames)
  expect_equal(lineage[1,1:8] %>% as.numeric, c(460513,2,1224,1807140,225057,225058,NA_integer_,460513))
  expect_equal(lineage[1,9:16] %>% as.character, c("uncultured Acidithiobacillaceae bacterium", "Bacteria", "Proteobacteria", "Acidithiobacillia", "Acidithiobacillales", "Acidithiobacillaceae", NA_character_, "uncultured Acidithiobacillaceae bacterium"))

  ## Valid id (genus)
  lineage <- getStandardLineageIdsAndScientificNamesByIdsAsDataFrame(taxdumpr, 1091)
  expect_equal(nrow(lineage), 1)
  expect_equal(ncol(lineage), 16)
  expect_equal(colnames(lineage), columnsNames)
  expect_equal(lineage[1,1:8] %>% as.numeric, c(1091, 2,1090,191410,191411,191412,1091,NA_integer_))
  expect_equal(lineage[1,9:16] %>% as.character, c("Chlorobium", "Bacteria", "Chlorobi", "Chlorobia", "Chlorobiales", "Chlorobiaceae", "Chlorobium", NA_character_))

  ## Valid ids, NA, and inexistent ids
  lineage <- getStandardLineageIdsAndScientificNamesByIdsAsDataFrame(taxdumpr, c(2, 290318, NA, 9876543210123456789, 1094))
  expect_equal(nrow(lineage), 5)
  expect_equal(ncol(lineage), 16)
  expect_equal(colnames(lineage), columnsNames)

  expect_equal(lineage[1,1:8] %>% as.numeric, c(2,2,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_))
  expect_equal(lineage[2,1:8] %>% as.numeric, c(1094,2,1090,191410,191411,191412,1091,1094))
  expect_equal(lineage[3,1:8] %>% as.numeric, c(290318,2,1090,191410,191411,191412,1091,1094))
  expect_equal(lineage[4,1:8] %>% as.numeric, c(9876543210123456789,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_))
  expect_equal(lineage[5,1:8] %>% as.numeric, c(NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_))

  expect_equal(lineage[1,9:16] %>% as.character, c("Bacteria","Bacteria",NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_,NA_integer_))
  expect_equal(lineage[2,9:16] %>% as.character, c("Chlorobium phaeovibrioides", "Bacteria", "Chlorobi", "Chlorobia", "Chlorobiales", "Chlorobiaceae", "Chlorobium", "Chlorobium phaeovibrioides"))
  expect_equal(lineage[3,9:16] %>% as.character, c("Chlorobium phaeovibrioides DSM 265", "Bacteria", "Chlorobi", "Chlorobia", "Chlorobiales", "Chlorobiaceae", "Chlorobium", "Chlorobium phaeovibrioides"))
  expect_equal(lineage[4,9:16] %>% as.character, c(NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_))
  expect_equal(lineage[5,9:16] %>% as.character, c(NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_))
})
