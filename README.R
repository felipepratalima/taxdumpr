#' ---
#' title: "taxdumpr"
#' output: github_document
#' ---
knitr::opts_chunk$set(echo = TRUE)

#'
#' **taxdumpr** is a R package which brings together a series of methods to manipulate NCBI's taxonomy data.
#' It was developed to work locally, thorugh the NCBI's **taxdump** downloaded files.
#' It was developed using the S4 class system, by Felipe Prata Lima (http://lbi.usp.br/membros/) and João Carlos Setubal (http://www.iq.usp.br/setubal/).
#'

#' ## **taxdump** files download
#'
#' The **taxdump** files can be download from the NCBI's ftp site, at ftp://ftp.ncbi.nih.gov/pub/taxonomy/.
#' You can download these files using **wget** with the command:
#'
#' wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
#'
#' And uncompress it using **tar**:
#'
#' tar zxvf taxdump.tar.gz
#'
#' This way you should obtain the following files:
#' ```{bash}
#' ls ~/taxdump/
#' ```
#'
#' In this docs, we are going to suppose that you downloaded and uncompressed this in your home folder.

#' ## Install
#'
#' Install the package using devtools:
#'
#' devtools::install_github("felipepratalima/taxdumpr")

#' ## Instantiate the **Taxdumpr** base class
#'
#' Load the package:
require(taxdumpr)

#'
#' Packages methods are organized around the **Taxdumpr** object. This can be instatiated by the **Taxdumpr** constructor, which requires:
#' 1. nodesDmpLocation: the path to the **nodes.dmp** file from **taxdump** downloaded files.
#' 2. namesDmpLocation: the same to **names.dmp**.
#' 3. mergedDmpLocation: the same to **merged.dmp**.
taxdumpr <- Taxdumpr(nodesDmpLocation = "~/taxdump/nodes.dmp", namesDmpLocation = "~/taxdump/names.dmp", mergedDmpLocation = "~/taxdump/merged.dmp")

#' ## Usage Examples
#'
#'
#' ### The getTaxonomyIdsByNames function should receive taxonomy name(s) and return taxonomy id(s):
#'
getTaxonomyIdsByNames(taxdumpr, "Corynebacterium")
getTaxonomyIdsByNames(taxdumpr, "Corynebacterium variabile")

#' It works with synonyms too:
getTaxonomyIdsByNames(taxdumpr, "Caseobacter")
getTaxonomyIdsByNames(taxdumpr, "Caseobacter polymorphus")

#' ### The getUpdatedIds function should receive old taxonomy id(s) and new (updated) taxonomy id(s). In the example the ID **319938** is updated to the new ID **288004** (*Beggiatoa leptomitoformis*):
#'
getUpdatedIds(taxdumpr, 319938)

#' Note that the non-updated ids are preserverd:
getUpdatedIds(taxdumpr, 288004)
getUpdatedIds(taxdumpr, c(319938, 1716, 1727, 288004))

#' **We recommend using *getUpdatedIds* always before starting to work with Taxdumpr**.

#'
#' ### The getScientificNamesByIds function should receive taxonomy id(s) and return the scientific name(s):
#'
getScientificNamesByIds(taxdumpr, 1716)
getScientificNamesByIds(taxdumpr, 1727)

#'
#' ### The getScientificNamesByNames function should receive taxonomy name(s) and return the scientific name(s):
#'
getScientificNamesByNames(taxdumpr, "Corynebacterium")
getScientificNamesByNames(taxdumpr, "Corynebacterium variabile")

#' Synonyms:
getScientificNamesByNames(taxdumpr, "Caseobacter")
getScientificNamesByNames(taxdumpr, "Caseobacter polymorphus")

#'
#' ### The getTaxonomyRanksByIds function should receive taxonomy id(s) and return ranks(s):
#'
getTaxonomyRanksByIds(taxdumpr, 1716)
getTaxonomyRanksByIds(taxdumpr, 1727)

#'
#' ### The getParentTaxonomyIdsByIds function should receive taxonomy id(s) and return parent id(s):
#'
getParentTaxonomyIdsByIds(taxdumpr, 1716)
getParentTaxonomyIdsByIds(taxdumpr, 1727)

#'
#' ### The getParentTaxonomyIdsByNames function should receive taxonomy name(s) and return parent taxonomy id(s):
#'
getParentTaxonomyIdsByNames(taxdumpr, "Corynebacterium")
getParentTaxonomyIdsByNames(taxdumpr, "Corynebacterium variabile")

#'
#' ### The getParentScientificNamesByIds function should receive taxonomy id(s) and return parent scientific name(s):
#'
getParentScientificNamesByIds(taxdumpr, 1716)
getParentScientificNamesByIds(taxdumpr, 1727)

#'
#' ### The getParentScientificNamesByNames function should receive taxonomy name(s) and return parent scientific name(s):
#'
getParentScientificNamesByNames(taxdumpr, "Corynebacterium")
getParentScientificNamesByNames(taxdumpr, "Corynebacterium variabile")

#'
#' ### The getStandardTaxonomyIdsByIds function should receive taxonomy id(s) of taxon(s) in non-standard level and return correspondent taxonomy id(s) in standard level:
#'
## Non-standard
getStandardTaxonomyIdsByIds(taxdumpr, 290318)
getStandardTaxonomyIdsByIds(taxdumpr, 274493)
getStandardTaxonomyIdsByIds(taxdumpr, 1783270)

## Standard
getStandardTaxonomyIdsByIds(taxdumpr, 1094)

#'
#' ### The getStandardTaxonomyIdsByNames function should receive taxonomy name(s) in non-standard level and return correspondent taxonomy id(s) in standard level:
#'
## Non-standard
getStandardTaxonomyIdsByNames(taxdumpr, "Chlorobium phaeovibrioides DSM 265")
getStandardTaxonomyIdsByNames(taxdumpr, "Chlorobium/Pelodictyon group")
getStandardTaxonomyIdsByNames(taxdumpr, "FCB group")

## Standard
getStandardTaxonomyIdsByNames(taxdumpr, "Chlorobium phaeovibrioides")

#'
#' ### The getStandardScientificNamesByNames function should receive taxonomy name(s) in non-standard level and return correspondent taxonomy name(s) in standard level:
#'
## Non-standard
getStandardScientificNamesByNames(taxdumpr, "Chlorobium phaeovibrioides DSM 265")
getStandardScientificNamesByNames(taxdumpr, "Chlorobium/Pelodictyon group")
getStandardScientificNamesByNames(taxdumpr, "FCB group")

## Standard
getStandardScientificNamesByNames(taxdumpr, "Chlorobium phaeovibrioides")

#'
#' ### The getLineageIdsByIds function should receive taxonomy id(s) and return complete taxonomy:
#'
getLineageIdsByIds(taxdumpr, 290318)

#'
#' ### The getStandardLineageIdsByIds function should receive taxonomy id(s) and return standard taxonomy:
#'
getStandardLineageIdsByIds(taxdumpr, 290318)

#'
#' ### The getStandardLineageIdsByIdsAsDataFrame function should receive taxonomy id(s) and return standard taxonomy as DF = [taxonomyId, superkingdomId, phylumId, classId, orderId, familyId, genusId, speciesId]:
#'
getStandardLineageIdsByIdsAsDataFrame(taxdumpr, 1094)

#'
#' ### The getStandardLineageIdsAndScientificNamesByIdsAsDataFrame function should receive taxonomy id(s) and return standard taxonomy as DF = [taxonomyId, superkingdomId, phylumId, classId, orderId, familyId, genusId, speciesId, taxonomyName, superkingdomName, phylumName, className, orderName, familyName, genusName, speciesName]:
#'
getStandardLineageIdsAndScientificNamesByIdsAsDataFrame(taxdumpr, 1094)
