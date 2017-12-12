require(magrittr)
require(dplyr)
require(hashmap)

# loadNames <- function(names.dmp.location = "./names.dmp") {
#   names.dmp <- read.table(names.dmp.location, header = F, sep = "|", strip.white = T, fill = T, stringsAsFactors = F, quote = "")
#   names.dmp <- names.dmp[,1:4]
#   names(names.dmp) <- c("id", "name", "uniqueName", "nameClass")
#   return(names.dmp)
# }
# names.dmp <- loadNames("/home/prata/taxdump/names.dmp")
# idToNameHashmap <- names.dmp %>% dplyr::filter(nameClass == "scientific name") %$%
#   hashmap(id, name)

# loadNodes <- function(nodes.dmp.location = "./nodes.dmp") {
#   nodes.dmp <- read.table(nodes.dmp.location, header = F, sep = "|", strip.white = T, fill = T, stringsAsFactors = F)
#   nodes.dmp <- nodes.dmp[,1:3]
#   names(nodes.dmp) <- c("id", "parentId", "rank")
#   return(nodes.dmp)
# }
# nodes.dmp <- loadNodes("/home/prata/taxdump/nodes.dmp")
# idToRankHashmap <- hashmap(nodes.dmp$id, nodes.dmp$rank)
# idToParentIdHashmap <- hashmap(nodes.dmp$id, nodes.dmp$parentId)

loadMerged <- function(merged.dmp.location = "./merged.dmp") {
  merged.dmp <- read.table(merged.dmp.location, header = F, sep = "|", strip.white = T, fill = T, stringsAsFactors = F)
  merged.dmp <- merged.dmp[,1:2]
  names(merged.dmp) <- c("oldTaxId", "newTaxId")
  return(merged.dmp)
}
merged.dmp <- loadMerged("/home/prata/taxdump/merged.dmp")

wasTaxonIdMerged <- function(taxonomyId, merged.dmp) {
  merged.filtered.df <- merged.dmp %>% filter(oldTaxId == taxonomyId)
  if (merged.filtered.df %>% nrow > 0) {
    return(T)
  }
  return(F)
}
wasTaxonIdMerged(1094, merged.dmp)

getTaxonId <- function(query.name, names.dmp) {
  ## names.selected <- names.dmp %>% filter(name == query.name)
  names.selected <- names.dmp[names.dmp$name == query.name,]

  if (names.selected %>% nrow > 1) {
    name.aux <- names.selected[names.selected$nameClass == "scientific name",]
    if (name.aux %>% nrow == 1) {
      names.selected <- name.aux
    } else {
      names.selected <- names.selected[1,]
    }
  }
  return(names.selected)
}
## "Caseobacter" %>% getTaxonId(names.dmp)
## "Prevotella" %>% getTaxonId(names.dmp)

# getScientificNameById <- function(query.id, names.dmp) {
#   query.name <- names.dmp[names.dmp$id == query.id & names.dmp$nameClass == "scientific name",]
#   query.name
# }
## 1716 %>% getScientificNameById(names.dmp)
## getTaxonId("Caseobacter", names.dmp)$id %>% getScientificNameById(names.dmp)

isValidName <- function(query.name, names.dmp) {
  if (query.name %>% getTaxonId(names.dmp) %>% nrow > 0) {
    T
  } else {
    F
  }
}
## "Caseobacter" %>% isValidName(names.dmp)
## "Inexistent" %>% isValidName(names.dmp)

getScientificNameByName <- function(query.name, names.dmp) {
  if (isValidName(query.name, names.dmp)) {
    query.id <- getTaxonId(query.name, names.dmp)$id
    getScientificNameById(query.id, names.dmp)
  } else {
    return(NA)
  }
}
## "Caseobacter" %>% getScientificNameByName(names.dmp)


getCompleteTaxonomyById <- function(query.id, nodes.dmp, names.dmp) {
  RANKS <- c("superkingdom", "phylum", "class", "order", "family", "genus", "species")
  completeTaxonomy <- data.frame(
    superkingdom = NA, phylum = NA, class = NA, order = NA, family = NA, genus = NA, species = NA
  )

  ## Added to check if the taxonomy ID really exist
  query.name <- getScientificNameById(query.id, names.dmp)
  if (query.name %>% nrow == 0) {
    return(completeTaxonomy)
  }

  queryId <- query.id
  while (queryId != 1) {
    query.name <- getScientificNameById(queryId, names.dmp)
    query.node <- nodes.dmp %>% filter(id == queryId) ## fazer getNodeById
    if (query.node$rank %in% RANKS) {
      completeTaxonomy[[query.node$rank]] <- query.name$name
    }
    queryId <- query.node$parentId
  }
  completeTaxonomy
}
## 1716 %>% getCompleteTaxonomyById(nodes.dmp, names.dmp)

getCompleteStandardTaxonomyById <- function(query.id, idToNameHashmap, idToRankHashmap, idToParentIdHashmap) {
  print(query.id)

  RANKS <- c("superkingdom", "phylum", "class", "order", "family", "genus", "species")
  completeTaxonomy <- data.frame(
    superkingdomId = NA, phylumId = NA, classId = NA, orderId = NA, familyId = NA, genusId = NA, speciesId = NA,
    superkingdomName = NA, phylumName = NA, className = NA, orderName = NA, familyName = NA, genusName = NA, speciesName = NA
  )

  ## Added to check if the taxonomy ID really exist
  if (idToNameHashmap$has_key(query.id) == FALSE) {
    return(completeTaxonomy)
  }

  queryId <- query.id
  while (queryId %>% is.na == FALSE && queryId %in% c(1,131567) == FALSE) {
    query.name <- idToNameHashmap$find(queryId)
    query.rank <- idToRankHashmap$find(queryId)
    if (query.rank %in% RANKS) {
      completeTaxonomy[[query.rank %>% paste0("Id")]] <- queryId
      completeTaxonomy[[query.rank %>% paste0("Name")]] <- query.name
    }
    queryId <- idToParentIdHashmap$find(queryId) ## fazer getNodeById
  }
  completeTaxonomy
}
getCompleteStandardTaxonomyById(2389, idToNameHashmap, idToRankHashmap, idToParentIdHashmap)
getCompleteStandardTaxonomyById(0, idToNameHashmap, idToRankHashmap, idToParentIdHashmap)
getCompleteStandardTaxonomyById(1, idToNameHashmap, idToRankHashmap, idToParentIdHashmap)
getCompleteStandardTaxonomyById(2, idToNameHashmap, idToRankHashmap, idToParentIdHashmap)
getCompleteStandardTaxonomyById(3, idToNameHashmap, idToRankHashmap, idToParentIdHashmap)
getCompleteStandardTaxonomyById(131567, idToNameHashmap, idToRankHashmap, idToParentIdHashmap)
getCompleteStandardTaxonomyById(1094, idToNameHashmap, idToRankHashmap, idToParentIdHashmap)
getCompleteStandardTaxonomyById(326426, idToNameHashmap, idToRankHashmap, idToParentIdHashmap)

getCompleteTaxonomyByName <- function(query.name, nodes.dmp, names.dmp) {
  query.id <- query.name %>% getTaxonId(names.dmp) %>% .[["id"]]
  completeTaxonomy <- query.id %>% getCompleteTaxonomyById(nodes.dmp, names.dmp)
  completeTaxonomy
}
## "Caseobacter" %>% getCompleteTaxonomyByName(nodes.dmp, names.dmp)

## If result is 0, then the taxonomy is fully compatible with NCBI
## If is 1, then it has nodes which is not present in NCBI taxonomy
## If is -1, then it has nodes which is not present in NCBI taxonomy
compareTaxonomyToNcbiTaxonomy <- function(taxonomy.df, nodes.dmp, names.dmp) {
  ## Get the NCBI taxonomy for the most deep taxon according to the name
  query.name <- NA
  for (i in 1:7) {
    ## Verify if the name is valid
    if (taxonomy.df[i] %>% is.na == F && taxonomy.df[i] %>% as.character %>% isValidName(names.dmp)) {
      query.name <- taxonomy.df[i] %>% as.character
    }
  }
  ncbiTaxonomy.df <- query.name %>% getCompleteTaxonomyByName(nodes.dmp, names.dmp)

  query.expected <- taxonomy.df %>% t %>% subset(!is.na(.[,1])) %>% nrow
  ncbi.expected <- ncbiTaxonomy.df %>% t %>% subset(!is.na(.[,1])) %>% nrow
  # query.result <- taxonomy.df %>%rbind(ncbiTaxonomy.df) %>% apply(2, function(x) {
  #   x %>% t %>% t %>% data.frame %>% filter(!is.na(.)) %>% unlist %>% unique %>% length
  # }) %>% sum

  list(
    expected = query.expected,
    result = query.expected - ncbi.expected
  )
}

getStandardId <- function(query.id, idToRankHashmap, idToParentIdHashmap) {
  RANKS <- c("superkingdom", "phylum", "class", "order", "family", "genus", "species")

  queryId <- query.id
  while (queryId %>% is.na == FALSE) {
    query.rank <- idToRankHashmap$find(queryId)

    if (query.rank %in% RANKS) {
      return(queryId)
    }

    queryId <- idToParentIdHashmap$find(queryId)
  }

  return(NA)
}
getStandardId(1094, idToRankHashmap, idToParentIdHashmap)
getStandardId(326426, idToRankHashmap, idToParentIdHashmap)

##============================================================================================
## Non standard nodes
##============================================================================================
compileNonStandardToStandardMapping <- function(taxdumpDir = "~/.taxdumpOptimization", parallel = TRUE) {
  nonStandard.nodes.dmp <- nodes.dmp %>%
    filter(rank %in% c("superkingdom", "phylum", "class", "order", "family", "genus", "species") == FALSE)

  idToRankCompleteHashmap <- hashmap(nodes.dmp$id, nodes.dmp$rank)
  idToParentIdCompleteHashmap <- hashmap(nodes.dmp$id, nodes.dmp$parentId)

  ## With parallel
  # no_cores <- parallel::detectCores() - 1
  # cl <- parallel::makeCluster(no_cores, type="FORK")
  # doParallel::registerDoParallel(cl)
  # nonStandardToStandardList <- foreach(i=nonStandard.nodes.dmp$id[1:100]) %dopar% getStandardId(i, idToRankCompleteHashmap, idToParentIdCompleteHashmap)
  # parallel::stopCluster(cl)

  ##
  nonStandardToStandardList <- lapply(nonStandard.nodes.dmp$id[1:100], getStandardId, idToRankCompleteHashmap, idToParentIdCompleteHashmap)

  ## Create non standard to standard map
  nonStandardToStandardMap <- data.frame(
    taxonomyId = nonStandard.nodes.dmp$id,
    standardId = unlist(nonStandardToStandardList)
  )

  ## Treat NAs
  nonStandardMapNAs <- nonStandardToStandardMap %>% filter(standardId %>% is.na) %>% mutate(standardId = taxonomyId)
  nonStandardToStandardMap <- nonStandardToStandardMap %>% filter(standardId %>% is.na == F)
  nonStandardToStandardMap <- nonStandardToStandardMap %>% rbind(nonStandardMapNAs)

  ## Store result in a tsv
  taxdumpDir <- "~/.taxdumpOptimzation" %>% path.expand
  dir.create(taxdumpDir, showWarnings = F)

  mapFilename <- taxdumpDir %>% paste0("/map.tsv") %>% path.expand
  # write.table(nonStandardToStandardMap, mapFilename, sep = "\t", quote = F, col.names = F, row.names = F)

  return(nonStandardToStandardMap)
}
teste <- compileNonStandardToStandardMapping()

loadNonStandardToStandardMapping <- function() {
  read.delim("~/.taxdumpOptimzation/map.tsv", header = F, col.names = c("taxonomyId", "standardId"))
}
nonStandardToStandardMap <- loadNonStandardToStandardMapping()
nonStandardToStandardHashmap <- hashmap(nonStandardToStandardMap$taxonomyId, nonStandardToStandardMap$standardId)
nonStandardToStandardHashmap$find(
  c(1412835, 1282423)
)

##
getStandardIdFromMap <- function(queryId, nonStandardToStandardMap) {
  queryResult <- nonStandardToStandardMap %>% filter(taxonomyId == queryId)

  if (nrow(queryResult) == 0) {
    return(queryId)
  }

  return(queryResult$standardId)
}
# getStandardIdFromMap(10490, nonStandardToStandardMap)
# getStandardIdFromMap(10497, nonStandardToStandardMap)

##============================================================================================
## Standard nodes
##============================================================================================
compileStandardNodes <- function() {
  standard.nodes.dmp <- nodes.dmp %>%
    filter(rank %in% c("superkingdom", "phylum", "class", "order", "family", "genus", "species"))

  library(doParallel)
  no_cores <- detectCores() - 1
  cl <- makeCluster(no_cores, type="FORK")
  registerDoParallel(cl)
  init <- Sys.time()
  parentsStandardIdsList <- foreach(i=standard.nodes.dmp$parentId) %dopar% getStandardIdFromMap(i, nonStandardToStandardMap)
  stopCluster(cl)
  paralelo <- Sys.time() - init

  standard.nodes.dmp$parentId <- unlist(parentsStandardIdsList)

  ## Store result in a tsv
  dir.create("~/.taxdumpOptimzation/" %>% path.expand, showWarnings = F)
  write.table(standard.nodes.dmp, "~/.taxdumpOptimzation/standard.nodes.tsv" %>% path.expand, sep = "\t", quote = F, col.names = F, row.names = F)
}

loadStandardNodes <- function() {
  standard.nodes.dmp <- read.delim("~/.taxdumpOptimzation/standard.nodes.tsv", header = F, col.names = c("id", "parentId", "rank"))
  standard.nodes.dmp$rank <- standard.nodes.dmp$rank %>% as.character
  return(standard.nodes.dmp)
}
standard.nodes.dmp <- loadStandardNodes()
idToRankHashmap <- hashmap(standard.nodes.dmp$id, standard.nodes.dmp$rank)
idToParentIdHashmap <- hashmap(standard.nodes.dmp$id, standard.nodes.dmp$parentId)

standard.names.dmp <- names.dmp %>% dplyr::filter(id %in% standard.nodes.dmp$id & nameClass == "scientific name")
idToNameHashmap <- hashmap(standard.names.dmp$id, standard.names.dmp$name)

getCompleteStandardTaxonomyById(1094, idToNameHashmap, idToRankHashmap, idToParentIdHashmap)
getCompleteStandardTaxonomyById(2389, idToNameHashmap, idToRankHashmap, idToParentIdHashmap)
##============================================================================================
## Get the complete taxonomies (hashmap)
##============================================================================================
init <- Sys.time()
completeTaxonomiesAsList <- lapply(standard.nodes.dmp$id, getCompleteStandardTaxonomyById, idToNameHashmap, idToRankHashmap, idToParentIdHashmap)
normal <- Sys.time() - init
normal

standard.nodes.dmp$id %>% length
completeTaxonomiesAsList %>% length

completeTaxonomies <- completeTaxonomiesAsList[[1]]
for (i in 2:length(completeTaxonomiesAsList)) {
  completeTaxonomies <- rbind(completeTaxonomies, completeTaxonomiesAsList[[i]])
}
completeTaxonomies$taxonomyId <- standard.nodes.dmp$id


##=========================================================================================
## Objects sizes
##=========================================================================================
print(object.size(names.dmp) , unit = "auto" , standard = "SI")
print(object.size(nodes.dmp) , unit = "auto" , standard = "SI")
print(object.size(merged.dmp) , unit = "auto" , standard = "SI")
print(object.size(merged.dmp) , unit = "auto" , standard = "SI")


##=========================================================================================
## KRAKEN section
##=========================================================================================
.getLcaAsDF <- function(lcaString) {
  lcaStringSplitted <- lcaString %>% strsplit(" ") %>% .[[1]]
  taxonsNumber <- lcaStringSplitted %>% length
  lcaDF <- data.frame(taxonomyId = NA, matchesNumber = NA)
  for (i in 1:taxonsNumber) {
    matchStringSplitted <- lcaStringSplitted[i] %>% strsplit(":") %>% .[[1]]
    if (i == 1) {
      lcaDF <- data.frame(taxonomyId = matchStringSplitted[1], matchesNumber = matchStringSplitted[2])
    } else {
      lcaDF <- data.frame(taxonomyId = matchStringSplitted[1], matchesNumber = matchStringSplitted[2]) %>% rbind(lcaDF)
    }
  }
  lcaDF$taxonomyId <- lcaDF$taxonomyId %>% as.character %>% as.numeric
  return(lcaDF)
}
krakenScores[50,6] %>% .getLcaAsDF
getCompleteTaxonomyById(0, nodes.dmp, names.dmp)
getCompleteTaxonomyById(1685, nodes.dmp, names.dmp)
getCompleteTaxonomyById(326426, nodes.dmp, names.dmp)
getCompleteTaxonomyById(866777, nodes.dmp, names.dmp)

getStandardId(0, idToRankHashmap, idToParentIdHashmap)
getStandardId(1685, idToRankHashmap, idToParentIdHashmap)
getStandardId(326426, idToRankHashmap, idToParentIdHashmap)
getStandardId(866777, idToRankHashmap, idToParentIdHashmap)

lapply(krakenScores[50,6] %>% getLcaAsDF %>% .$taxonomyId %>% as.character %>% as.numeric, getStandardId, idToRankHashmap, idToParentIdHashmap) %>% unlist

.convertIds <- function(taxonomyIds, nonStandardToStandardHashmap) {
  standardIds <- nonStandardToStandardHashmap$find(taxonomyIds)
  standardIds <- ifelse(standardIds %>% is.na, taxonomyIds, standardIds)
  return(standardIds)
}

.summarizeAndComputePs <- function(lcaDF) {
  lcaDF$matchesNumber <- lcaDF$matchesNumber %>% as.character %>% as.numeric
  lcaDF <- lcaDF %>% group_by(taxonomyId) %>% dplyr::summarise(matchesNumber = sum(matchesNumber))
  lcaDF$P <- lcaDF$matchesNumber / sum(lcaDF$matchesNumber)
  return(lcaDF)
}

computeScore <- function(krakenLcaString, nonStandardToStandardHashmap) {
  lcaDF <- .getLcaAsDF(krakenLcaString)
  lcaDF$taxonomyId <- .convertIds(lcaDF$taxonomyId, nonStandardToStandardHashmap)
  lcaDF <- .summarizeAndComputePs(lcaDF)

  if (nrow(lcaDF) == 1) {
    return(lcaDF$P)
  }

  return(lcaDF %>% filter(taxonomyId != 0) %>% filter(P == max(P)) %>% .$P)
}
computeScore(krakenScores[50,6], nonStandardToStandardHashmap)

addScore <- function(krakenClassification) {
  lcaDf <- krakenClassification[,6] %>% getLcaAsDF
  speciesLcaDf <- lcaDf %>% addSpeciesId

  if (nrow(speciesLcaDf) == 1) {
    krakenClassification$speciesId <- krakenClassification[,3]
    krakenClassification$newMatchesNumber <- 0
    krakenClassification$newP <- 1
    return(krakenClassification)
  }

  newLcaDf <- speciesLcaDf %>% summarizeBySpecies
  selectedLcaDf <- newLcaDf %>% selectByScore
  krakenClassification$speciesId <- selectedLcaDf$speciesId
  krakenClassification$newMatchesNumber <- selectedLcaDf$newMatchesNumber
  krakenClassification$newP <- selectedLcaDf$newP
  return(krakenClassification)
}



krakenScores <- read.delim("/home/prata/samples/mix1/mt/kraken/mix1_mt_r1.filtered.kraken.score", header = F)
krakenScores$V6 <- krakenScores$V6 %>% as.character
krakenScoresUnclassified <- krakenScores %>% filter(V1 == "U")
krakenScores <- krakenScores %>% filter(V1 == "C")

init <- Sys.time()
standardPs <- lapply(krakenScores$V6[1:100], computeScore, nonStandardToStandardHashmap)
normal <- Sys.time() - init
normal

##
init <- Sys.time()
krakenIds <- .convertIds(krakenScores$V3, nonStandardToStandardHashmap) %>% unique %>% sort
completeTaxonomiesAsList <- lapply(krakenIds, getCompleteStandardTaxonomyById, idToNameHashmap, idToRankHashmap, idToParentIdHashmap)
normal <- Sys.time() - init
normal
completeTaxonomies <- completeTaxonomiesAsList[[1]]
for (i in 2:length(completeTaxonomiesAsList)) {
  completeTaxonomies <- rbind(completeTaxonomies, completeTaxonomiesAsList[[i]])
}
completeTaxonomies$taxonomyId <- krakenIds

microbenchmark::microbenchmark(
  namesToIdsHashmap <- hashmap(names.dmp$name, names.dmp$id),
  times = 1
)

microbenchmark::microbenchmark(
  {
    CaseobacterId <- namesToIdsHashmap$find("Caseobacter")
    CaseobacterName <- idToNameHashmap$find(CaseobacterId)
  },
  times = 1
)
