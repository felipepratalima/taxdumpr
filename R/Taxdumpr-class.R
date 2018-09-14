#'
#' Class structure
#'
setClass(

  "Taxdumpr",

  representation = list(
    .nodesDmpLocation = "character",
    .namesDmpLocation = "character",
    .mergedDmpLocation = "character",
    .idsToNames = "Rcpp_Hashmap",
    .namesToIds = "Rcpp_Hashmap",
    .idsToRanks = "Rcpp_Hashmap",
    .idsToParentIds = "Rcpp_Hashmap",
    .oldIdsToNewIds = "Rcpp_Hashmap",
    .STANDARD_RANKS = "character"
  ),

  prototype = list(
    .nodesDmpLocation = NA_character_,
    .namesDmpLocation = NA_character_,
    .mergedDmpLocation = NA_character_,
    .idsToNames = NULL,
    .namesToIds = NULL,
    .idsToRanks = NULL,
    .idsToParentIds = NULL,
    .oldIdsToNewIds = NULL,
    .STANDARD_RANKS = c("superkingdom", "phylum", "class", "order", "family", "genus", "species")
  )

)


#'
#' Constructor
#'
Taxdumpr <- function(nodesDmpLocation, namesDmpLocation, mergedDmpLocation) {
  object <- new("Taxdumpr")

  object@.nodesDmpLocation <- nodesDmpLocation
  object@.namesDmpLocation <- namesDmpLocation
  object@.mergedDmpLocation <- mergedDmpLocation

  nodes.dmp <- loadNodes(object@.nodesDmpLocation)
  names.dmp <- loadNames(object@.namesDmpLocation)
  merged.dmp <- loadMerged(object@.mergedDmpLocation)

  object@.idsToNames <- getIdsToNamesHashmap(names.dmp)
  object@.namesToIds <- getNamesToIdsHashmap(names.dmp)
  object@.idsToRanks <- getIdsToRanksHashmap(nodes.dmp)
  object@.idsToParentIds <- getIdsToParentIdsHashmap(nodes.dmp)
  object@.oldIdsToNewIds <- getOldIdsToNewIdsHashmap(merged.dmp)

  return(object)
}

#'
#'
#'
setGeneric("getUpdatedIds", function(x, taxonomyIds) standardGeneric("getUpdatedIds"))


#'
#'
#'
setMethod("getUpdatedIds", "Taxdumpr", function(x, taxonomyIds) {
  mergedIds <- x@.oldIdsToNewIds$find(taxonomyIds)
  taxonomyIds[mergedIds %>% is.na == F] <- mergedIds[mergedIds %>% is.na == F]
  return(taxonomyIds)
})


#'
#'
#'
setGeneric("getTaxonomyIdsByNames", function(x, taxonomyNames) standardGeneric("getTaxonomyIdsByNames"))


#'
#'
#'
setMethod("getTaxonomyIdsByNames", "Taxdumpr", function(x, taxonomyNames) {
  taxonomyIds <- x@.namesToIds$find(taxonomyNames)
  return(taxonomyIds)
})


#'
#'
#'
setGeneric("getScientificNamesByIds", function(x, taxonomyIds) standardGeneric("getScientificNamesByIds"))


#'
#'
#'
setMethod("getScientificNamesByIds", "Taxdumpr", function(x, taxonomyIds) {
  taxonomyIds <- getUpdatedIds(x, taxonomyIds)
  taxonomyNames <- x@.idsToNames$find(taxonomyIds)
  return(taxonomyNames)
})


#'
#'
#'
setGeneric("getScientificNamesByNames", function(x, taxonomyNames) standardGeneric("getScientificNamesByNames"))


#'
#'
#'
setMethod("getScientificNamesByNames", "Taxdumpr", function(x, taxonomyNames) {
  taxonomyIds <- getTaxonomyIdsByNames(x, taxonomyNames)
  scientificNames <- getScientificNamesByIds(x, taxonomyIds)
  return(scientificNames)
})


#'
#'
#'
setGeneric("getTaxonomyRanksByIds", function(x, taxonomyIds) standardGeneric("getTaxonomyRanksByIds"))


#'
#'
#'
setMethod("getTaxonomyRanksByIds", "Taxdumpr", function(x, taxonomyIds) {
  taxonomyRanks <- x@.idsToRanks$find(taxonomyIds)
  return(taxonomyRanks)
})

#'
#'
#'
setGeneric("getTaxonomyRanksByNames", function(x, taxonomyNames) standardGeneric("getTaxonomyRanksByNames"))


#'
#'
#'
setMethod("getTaxonomyRanksByNames", "Taxdumpr", function(x, taxonomyNames) {
  taxonomyIds <- getTaxonomyIdsByNames(x, taxonomyNames)
  taxonomyRanks <- getTaxonomyRanksByIds(x, taxonomyIds)
  return(taxonomyRanks)
})


#'
#'
#' @export
setGeneric("getParentTaxonomyIdsByIds", function(x, taxonomyIds) standardGeneric("getParentTaxonomyIdsByIds"))


#'
#'
#' @export
setMethod("getParentTaxonomyIdsByIds", "Taxdumpr", function(x, taxonomyIds) {
  parentId <- x@.idsToParentIds$find(taxonomyIds)
  return(parentId)
})


#'
#'
#'
setGeneric("getParentTaxonomyIdsByNames", function(x, taxonomyNames) standardGeneric("getParentTaxonomyIdsByNames"))

#'
#'
#'
setMethod("getParentTaxonomyIdsByNames", "Taxdumpr", function(x, taxonomyNames) {
  taxonomyIds <- getTaxonomyIdsByNames(x, taxonomyNames)
  parentIds <- getParentTaxonomyIdsByIds(x, taxonomyIds)
  return(parentIds)
})


#'
#'
#'
setGeneric("getParentScientificNamesByIds", function(x, taxonomyIds) standardGeneric("getParentScientificNamesByIds"))


#'
#'
#'
setMethod("getParentScientificNamesByIds", "Taxdumpr", function(x, taxonomyIds) {
  parentIds <- getParentTaxonomyIdsByIds(x, taxonomyIds)
  parentScientificNames <- getScientificNamesByIds(x, parentIds)
  return(parentScientificNames)
})



#'
#'
#'
setGeneric("getParentScientificNamesByNames", function(x, taxonomyNames) standardGeneric("getParentScientificNamesByNames"))


#'
#'
#'
setMethod("getParentScientificNamesByNames", "Taxdumpr", function(x, taxonomyNames) {
  taxonomyIds <- getTaxonomyIdsByNames(x, taxonomyNames)
  parentIds <- getParentTaxonomyIdsByIds(x, taxonomyIds)
  parentScientificNames <- getScientificNamesByIds(x, parentIds)
  return(parentScientificNames)
})


#'
#'
#'
setGeneric("getStandardTaxonomyIdsByIds", function(x, taxonomyIds) standardGeneric("getStandardTaxonomyIdsByIds"))


#'
#'
#'
setMethod("getStandardTaxonomyIdsByIds", "Taxdumpr", function(x, taxonomyIds) {
  ## Store the mapping in a hash
  idsToStandardIds <- hashmap::hashmap(2, 2)

  ## Get non repetitive ids
  uniqueIds <- taxonomyIds

  ## Search standard taxonomy ids
  for (taxonomyId in uniqueIds) {
    ## Get rank of the taxonomy id
    # taxonomyRank <- x@.idsToRanks$find(taxonomyId)
    taxonomyRank <- getTaxonomyRanksByIds(x, taxonomyId)

    ## Verify if taxonomy id is already from standard taxonomy rank
    if (taxonomyRank %in% x@.STANDARD_RANKS) {
      ## If yes, then maintain taxonomy id
      idsToStandardIds$insert(taxonomyId, taxonomyId)
    } else {
      ## If not, look for standard taxonomy id as below
      ## Get parent id
      queryId <- x@.idsToParentIds$find(taxonomyId)

      ## Search by parent to parent
      while (queryId %>% is.na == FALSE) {
        ## Get the rank
        queryRank <- x@.idsToRanks$find(queryId)

        ## Verify if rank is standard taxonomy rank
        if (queryRank %in% x@.STANDARD_RANKS) {
          ## If yes, then add to the map
          idsToStandardIds$insert(taxonomyId, queryId)

          ## And stop the search
          queryId <- NA
        } else {
          ## If not, search from the next parent
          queryId <- x@.idsToParentIds$find(queryId)
        }
      }
    }
  }

  ## Replace the taxonomy ids with the standard taxonomy ids
  standardIds <- idsToStandardIds$find(taxonomyIds)

  ## And return them
  return(standardIds)
})


#'
#'
#'
setGeneric("getStandardTaxonomyIdsByNames", function(x, taxonomyNames) standardGeneric("getStandardTaxonomyIdsByNames"))


#'
#'
#'
setMethod("getStandardTaxonomyIdsByNames", "Taxdumpr", function(x, taxonomyNames) {
  taxonomyIds <- getTaxonomyIdsByNames(x, taxonomyNames)
  standardIds <- getStandardTaxonomyIdsByIds(x, taxonomyIds)
  return(standardIds)
})


#'
#'
#'
setGeneric("getStandardScientificNamesByNames", function(x, taxonomyNames) standardGeneric("getStandardScientificNamesByNames"))


#'
#'
#'
setMethod("getStandardScientificNamesByNames", "Taxdumpr", function(x, taxonomyNames) {
  standardIds <- getStandardTaxonomyIdsByNames(x, taxonomyNames)
  standardScientificNames <- getScientificNamesByIds(x, standardIds)
  return(standardScientificNames)
})


#'
#'
#'
setGeneric("getLineageIdsByIds", function(x, taxonomyIds) standardGeneric("getLineageIdsByIds"))


#'
#'
#'
setMethod("getLineageIdsByIds", "Taxdumpr", function(x, taxonomyIds) {
  ## Create a data frame to store the taxonomy id and its taxonomy ids in lineage
  lineagesDf <- data.frame(taxonomyId = NA_integer_, lineageId = NA_integer_)

  ## Select unique ids to avoid repeats
  uniqueTaxonomyIds <- unique(taxonomyIds)

  ## For each taxonomy id, retrieve its lineage
  for (taxonomyId in uniqueTaxonomyIds) {
    ## Init lineage by the own taxonomy id
    currentLineageDf <- data.frame(taxonomyId = taxonomyId, lineageId = taxonomyId)

    ## Get its parent id to search the other nodes in the tree
    parentId <- getParentTaxonomyIdsByIds(x, taxonomyId)
    while (parentId %>% is.na == FALSE && parentId %in% c(1, 131567) == FALSE) {
      ## If it has a parent id, add the parent to the lineage
      currentLineageDf <- data.frame(taxonomyId = taxonomyId, lineageId = parentId) %>% rbind(currentLineageDf)

      ## Look for the next parent
      parentId <- getParentTaxonomyIdsByIds(x, parentId)
    }

    ## Store the lineage for the taxonomy id
    lineagesDf <- lineagesDf %>% rbind(currentLineageDf)
  }

  ## Remove NAs
  lineagesDf <- lineagesDf %>% dplyr::filter(taxonomyId %>% is.na == FALSE)

  ## Return retrieved lineages
  return(lineagesDf)
})


#'
#'
#'
# getLineageIdsByIds <- function(x, taxonomyIds) {
#   ## Create a data frame to store the taxonomy id and its taxonomy ids in lineage
#   lineagesDf <- data.frame(taxonomyId = NA_integer_, lineageId = NA_integer_)
#
#   ## Select unique ids to avoid repeats
#   uniqueTaxonomyIds <- unique(taxonomyIds)
#
#   ## For each taxonomy id, retrieve its lineage
#   for (taxonomyId in uniqueTaxonomyIds) {
#     ## Init lineage by the own taxonomy id
#     currentLineageDf <- data.frame(taxonomyId = taxonomyId, lineageId = taxonomyId)
#
#     ## Get its parent id to search the other nodes in the tree
#     parentId <- getParentTaxonomyIdsByIds(x, taxonomyId)
#     while (parentId %>% is.na == FALSE && parentId %in% c(1, 131567) == FALSE) {
#       ## If it has a parent id, add the parent to the lineage
#       currentLineageDf <- data.frame(taxonomyId = taxonomyId, lineageId = parentId) %>% rbind(currentLineageDf)
#
#       ## Look for the next parent
#       parentId <- getParentTaxonomyIdsByIds(x, parentId)
#     }
#
#     ## Store the lineage for the taxonomy id
#     lineagesDf <- lineagesDf %>% rbind(currentLineageDf)
#   }
#
#   ## Remove NAs
#   lineagesDf <- lineagesDf %>% dplyr::filter(taxonomyId %>% is.na == FALSE)
#
#   ## Return retrieved lineages
#   return(lineagesDf)
# }


#'
#'
#'
# setMethod("getStandardScientificNamesByNames", "Taxdumpr", function(x, taxonomyNames) {
#   standardIds <- getStandardTaxonomyIdsByNames(x, taxonomyNames)
#   standardScientificNames <- getScientificNamesByIds(x, standardIds)
#   return(standardScientificNames)
# })


#'
#'
#'
getStandardLineageIdsByIds <- function(x, taxonomyIds) {
  lineagesDf <- getLineageIdsByIds(x, taxonomyIds)
  ranks <- getTaxonomyRanksByIds(x, lineagesDf$lineageId)
  isStandard <- ranks %in% c(x@.STANDARD_RANKS, NA)
  lineagesDf <- lineagesDf[isStandard,]

  ## Return retrieved lineages
  return(lineagesDf)
}


#'
#'
#'
# V1
# getStandardLineageIdsByIdsAsDataFrame <- function(x, taxonomyIds) {
#   lineagesDf <- getLineageIdsByIds(x, taxonomyIds)
#   lineagesDf$ranks <- getTaxonomyRanksByIds(x, lineagesDf$lineageId)
#   isStandard <- lineagesDf$ranks %in% c(x@.STANDARD_RANKS, NA)
#   lineagesDf <- lineagesDf[isStandard,]
#   try(rownames(lineagesDf) <- getTaxonomyRanksByIds(x, lineagesDf$lineageId), silent = T) ## TODO: threat this case without a try statement
#   standardIds <- lineagesDf[x@.STANDARD_RANKS,]$lineageId ## 7 standard ids, has NA for missing levels
#   auxDf <- c(taxonomyIds, standardIds) %>% t %>% as.data.frame
#   auxColnames <- c("taxonomy", x@.STANDARD_RANKS) %>% paste0(., "Id")
#   colnames(auxDf) <- auxColnames
#
#   ## Return retrieved lineages
#   return(auxDf)
# }
# V2
getStandardLineageIdsByIdsAsDataFrame <- function(x, taxonomyIds) {
  lineagesDf <- getLineageIdsByIds(x, taxonomyIds)
  lineagesDf$rank <- getTaxonomyRanksByIds(x, lineagesDf$lineageId)
  isStandard <- lineagesDf$rank %in% c(x@.STANDARD_RANKS, NA)
  lineagesDf <- lineagesDf[isStandard,]

  lineagesDf <-
    data.frame(taxonomyId = NA, lineageId = NA, rank = x@.STANDARD_RANKS) %>%
    rbind(lineagesDf)

  lineagesDf <- reshape2::dcast(lineagesDf, taxonomyId ~ rank, value.var = "lineageId")
  lineagesDf <- lineagesDf[,c("taxonomyId", x@.STANDARD_RANKS)]
  colnames(lineagesDf) <- c("taxonomy", x@.STANDARD_RANKS) %>% paste0(., "Id")

  if (NA %in% taxonomyIds == FALSE) {
    lineagesDf <- lineagesDf %>% dplyr::filter(taxonomyId %>% is.na == FALSE)
  }

  ## Return retrieved lineages
  return(lineagesDf)
}

# taxonomyIds <- c(NA, NA)
# taxonomyIds <- c(2, 290318, 1094, 454698865198)
# taxonomyIds <- 454698865198
# taxonomyIds <- 460513 ## incomplete
# x <- Taxdumpr(nodesDmpLocation = "~/taxdump/nodes.dmp", namesDmpLocation = "~/taxdump/names.dmp")
# getStandardLineageIdsByIdsAsDataFrame(x, taxonomyIds)
# getStandardLineageIdsByIdsAsDataFrame(x, 454698865198)
# getStandardLineageIdsByIdsAsDataFrame(x, NA)
# getStandardLineageIdsByIdsAsDataFrame(x, c(NA, 454698865198))
# getStandardLineageIdsByIdsAsDataFrame(x, c(1094, 454698865198))
# getStandardLineageIdsByIdsAsDataFrame(x, 460513)

getStandardLineageIdsAndScientificNamesByIdsAsDataFrame <- function(x, taxonomyIds) {
  lineagesDf <- getStandardLineageIdsByIdsAsDataFrame(x, taxonomyIds)
  lineagesDf$taxonomyName <- getScientificNamesByIds(x, lineagesDf$taxonomyId)
  lineagesDf$superkingdomName <- getScientificNamesByIds(x, lineagesDf$superkingdomId)
  lineagesDf$phylumName <- getScientificNamesByIds(x, lineagesDf$phylumId)
  lineagesDf$className <- getScientificNamesByIds(x, lineagesDf$classId)
  lineagesDf$orderName <- getScientificNamesByIds(x, lineagesDf$orderId)
  lineagesDf$familyName <- getScientificNamesByIds(x, lineagesDf$familyId)
  lineagesDf$genusName <- getScientificNamesByIds(x, lineagesDf$genusId)
  lineagesDf$speciesName <- getScientificNamesByIds(x, lineagesDf$speciesId)

  return(lineagesDf)
}
