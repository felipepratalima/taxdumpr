#'
#'
#'
setClass(
  "KrakenClassifications",

  representation = list(
    filename = "character",
    classifications = "data.frame"
  ),

  validity = function(object) {
    print(object@filename)
    if (file.exists(object@filename) == FALSE) {
      return(FALSE)
    }

    return(TRUE)
  }
)

#'
#'
#'
setGeneric("getFilename", function(self) {
  standardGeneric("getFilename")
})

#'
#'
#'
setMethod("getFilename", "KrakenClassifications", function(self) {
  return(self@filename)
})

#'
#'
#'
setGeneric("getClassifications", function(self) {
  standardGeneric("getClassifications")
})

#'
#'
#'
setMethod("getClassifications", "KrakenClassifications", function(self) {
  return(self@classifications)
})

#'
#'
#'
setGeneric("setClassifications", function(self, value) {
  standardGeneric("setClassifications")
})

#'
#'
#'
setMethod("setClassifications", "KrakenClassifications", function(self, value) {
  self@classifications <- value
  return(self)
})

#' creates a new kraken classifications object
#'
#' loads a kraken result into a data frame, checks its structure, and stores to further analysis
#'
#' @param krakenClassificationsFilename filename of a kraken result (with location)
#' @examples
#'
#' krakenClassifications <- newKrakenClassifications("/home/user/kraken_analysis/kraken_classifications.tsv")
#'
newKrakenClassifications <- function(krakenClassificationsFilename = "") {
  object <- new("KrakenClassifications")

  object@filename <- krakenClassificationsFilename

  object@classifications <- read.delim(object@filename, header = F)
  if (ncol(object@classifications) != 5) {
    cat("Check file structure\n")
    return(NULL)
  }
  names(object@classifications) <- c("status", "sequenceId", "taxonomyId", "sequenceLength", "lca")

  validObject(object)

  return(object)
}

## Developing and running
# krakenClassifications <- newKrakenClassifications("/home/prata/samples/mix1/sh/kraken/mix1_shotgun_r1.filtered.kraken")
# head(getClassifications(krakenClassifications))
# dim(krakenClassifications@classifications)
