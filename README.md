taxdumpr
================
prata
Wed Mar 7 23:55:23 2018

``` r
knitr::opts_chunk$set(echo = TRUE)
```

**taxdumpr** is a R package which brings together a series of methods to manipulate NCBI's taxonomy data. It was developed to work locally, thorugh the NCBI's **taxdump** downloaded files. It was developed using the S4 class system, by Felipe Prata Lima (<http://lbi.usp.br/membros/>) and João Carlos Setubal (<http://www.iq.usp.br/setubal/>).

**taxdump** files download
--------------------------

The **taxdump** files can be download from the NCBI's ftp site, at <ftp://ftp.ncbi.nih.gov/pub/taxonomy/>. You can download these files using **wget** with the command:

wget <ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz>

And uncompress it using **tar**:

tar zxvf taxdump.tar.gz

This way you should obtain the following files:

``` bash
ls ~/taxdump/
```

    ## citations.dmp
    ## delnodes.dmp
    ## division.dmp
    ## gc.prt
    ## gencode.dmp
    ## merged.dmp
    ## names.csv
    ## names.dmp
    ## nodes.dmp
    ## readme.txt

In this docs, we are going to suppose that you downloaded and uncompressed this in your home folder. \#\# Install

Install the package using devtools:

devtools::install\_github("felipepratalima/taxdumpr") \#\# Instantiate the **Taxdumpr** base class

Load the package:

``` r
require(taxdumpr)
```

    ## Loading required package: taxdumpr

Packages methods are organized around the **Taxdumpr** object. This can be instatiated by the **Taxdumpr** constructor, which requires: 1. nodesDmpLocation: the path to the **nodes.dmp** file from **taxdump** downloaded files. 2. namesDmpLocation: the same to **names.dmp**.

``` r
taxdumpr <- Taxdumpr(nodesDmpLocation = "~/taxdump/nodes.dmp", namesDmpLocation = "~/taxdump/names.dmp")
```

Usage Examples
--------------

### The getTaxonomyIdsByNames function should receive taxonomy name(s) and return taxonomy id(s):

``` r
getTaxonomyIdsByNames(taxdumpr, "Corynebacterium")
```

    ## [1] 1716

``` r
getTaxonomyIdsByNames(taxdumpr, "Corynebacterium variabile")
```

    ## [1] 1727

It works with synonyms too:

``` r
getTaxonomyIdsByNames(taxdumpr, "Caseobacter")
```

    ## [1] 1716

``` r
getTaxonomyIdsByNames(taxdumpr, "Caseobacter polymorphus")
```

    ## [1] 1727

### The getScientificNamesByIds function should receive taxonomy id(s) and return the scientific name(s):

``` r
getScientificNamesByIds(taxdumpr, 1716)
```

    ## [1] "Corynebacterium"

``` r
getScientificNamesByIds(taxdumpr, 1727)
```

    ## [1] "Corynebacterium variabile"

### The getScientificNamesByNames function should receive taxonomy name(s) and return the scientific name(s):

``` r
getScientificNamesByNames(taxdumpr, "Corynebacterium")
```

    ## [1] "Corynebacterium"

``` r
getScientificNamesByNames(taxdumpr, "Corynebacterium variabile")
```

    ## [1] "Corynebacterium variabile"

Synonyms:

``` r
getScientificNamesByNames(taxdumpr, "Caseobacter")
```

    ## [1] "Corynebacterium"

``` r
getScientificNamesByNames(taxdumpr, "Caseobacter polymorphus")
```

    ## [1] "Corynebacterium variabile"

### The getTaxonomyRanksByIds function should receive taxonomy id(s) and return ranks(s):

``` r
getTaxonomyRanksByIds(taxdumpr, 1716)
```

    ## [1] "genus"

``` r
getTaxonomyRanksByIds(taxdumpr, 1727)
```

    ## [1] "species"

### The getParentTaxonomyIdsByIds function should receive taxonomy id(s) and return parent id(s):

``` r
getParentTaxonomyIdsByIds(taxdumpr, 1716)
```

    ## [1] 1653

``` r
getParentTaxonomyIdsByIds(taxdumpr, 1727)
```

    ## [1] 1716

### The getParentTaxonomyIdsByNames function should receive taxonomy name(s) and return parent taxonomy id(s):

``` r
getParentTaxonomyIdsByNames(taxdumpr, "Corynebacterium")
```

    ## [1] 1653

``` r
getParentTaxonomyIdsByNames(taxdumpr, "Corynebacterium variabile")
```

    ## [1] 1716

### The getParentScientificNamesByIds function should receive taxonomy id(s) and return parent scientific name(s):

``` r
getParentScientificNamesByIds(taxdumpr, 1716)
```

    ## [1] "Corynebacteriaceae"

``` r
getParentScientificNamesByIds(taxdumpr, 1727)
```

    ## [1] "Corynebacterium"

### The getParentScientificNamesByNames function should receive taxonomy name(s) and return parent scientific name(s):

``` r
getParentScientificNamesByNames(taxdumpr, "Corynebacterium")
```

    ## [1] "Corynebacteriaceae"

``` r
getParentScientificNamesByNames(taxdumpr, "Corynebacterium variabile")
```

    ## [1] "Corynebacterium"

### The getStandardTaxonomyIdsByIds function should receive taxonomy id(s) of taxon(s) in non-standard level and return correspondent taxonomy id(s) in standard level:

``` r
## Non-standard
getStandardTaxonomyIdsByIds(taxdumpr, 290318)
```

    ## [1] 1094

``` r
getStandardTaxonomyIdsByIds(taxdumpr, 274493)
```

    ## [1] 191412

``` r
getStandardTaxonomyIdsByIds(taxdumpr, 1783270)
```

    ## [1] 2

``` r
## Standard
getStandardTaxonomyIdsByIds(taxdumpr, 1094)
```

    ## [1] 1094

### The getStandardTaxonomyIdsByNames function should receive taxonomy name(s) in non-standard level and return correspondent taxonomy id(s) in standard level:

``` r
## Non-standard
getStandardTaxonomyIdsByNames(taxdumpr, "Chlorobium phaeovibrioides DSM 265")
```

    ## [1] 1094

``` r
getStandardTaxonomyIdsByNames(taxdumpr, "Chlorobium/Pelodictyon group")
```

    ## [1] 191412

``` r
getStandardTaxonomyIdsByNames(taxdumpr, "FCB group")
```

    ## [1] 2

``` r
## Standard
getStandardTaxonomyIdsByNames(taxdumpr, "Chlorobium phaeovibrioides")
```

    ## [1] 1094

### The getStandardScientificNamesByNames function should receive taxonomy name(s) in non-standard level and return correspondent taxonomy name(s) in standard level:

``` r
## Non-standard
getStandardScientificNamesByNames(taxdumpr, "Chlorobium phaeovibrioides DSM 265")
```

    ## [1] "Chlorobium phaeovibrioides"

``` r
getStandardScientificNamesByNames(taxdumpr, "Chlorobium/Pelodictyon group")
```

    ## [1] "Chlorobiaceae"

``` r
getStandardScientificNamesByNames(taxdumpr, "FCB group")
```

    ## [1] "Bacteria"

``` r
## Standard
getStandardScientificNamesByNames(taxdumpr, "Chlorobium phaeovibrioides")
```

    ## [1] "Chlorobium phaeovibrioides"

### The getLineageIdsByIds function should receive taxonomy id(s) and return complete taxonomy:

``` r
getLineageIdsByIds(taxdumpr, 290318)
```

    ##    taxonomyId lineageId
    ## 1      290318         2
    ## 2      290318   1783270
    ## 3      290318     68336
    ## 4      290318      1090
    ## 5      290318    191410
    ## 6      290318    191411
    ## 7      290318    191412
    ## 8      290318    274493
    ## 9      290318      1091
    ## 10     290318      1094
    ## 11     290318    290318

### The getStandardLineageIdsByIds function should receive taxonomy id(s) and return standard taxonomy:

``` r
getStandardLineageIdsByIds(taxdumpr, 290318)
```

    ##    taxonomyId lineageId
    ## 1      290318         2
    ## 4      290318      1090
    ## 5      290318    191410
    ## 6      290318    191411
    ## 7      290318    191412
    ## 9      290318      1091
    ## 10     290318      1094

### The getStandardLineageIdsByIdsAsDataFrame function should receive taxonomy id(s) and return standard taxonomy as DF = \[taxonomyId, superkingdomId, phylumId, classId, orderId, familyId, genusId, speciesId\]:

``` r
getStandardLineageIdsByIdsAsDataFrame(taxdumpr, 1094)
```

    ##   taxonomyId superkingdomId phylumId classId orderId familyId genusId
    ## 1       1094              2     1090  191410  191411   191412    1091
    ##   speciesId
    ## 1      1094

### The getStandardLineageIdsAndScientificNamesByIdsAsDataFrame function should receive taxonomy id(s) and return standard taxonomy as DF = \[taxonomyId, superkingdomId, phylumId, classId, orderId, familyId, genusId, speciesId, taxonomyName, superkingdomName, phylumName, className, orderName, familyName, genusName, speciesName\]:

``` r
getStandardLineageIdsAndScientificNamesByIdsAsDataFrame(taxdumpr, 1094)
```

    ##   taxonomyId superkingdomId phylumId classId orderId familyId genusId
    ## 1       1094              2     1090  191410  191411   191412    1091
    ##   speciesId               taxonomyName superkingdomName phylumName
    ## 1      1094 Chlorobium phaeovibrioides         Bacteria   Chlorobi
    ##   className    orderName    familyName  genusName
    ## 1 Chlorobia Chlorobiales Chlorobiaceae Chlorobium
    ##                  speciesName
    ## 1 Chlorobium phaeovibrioides
