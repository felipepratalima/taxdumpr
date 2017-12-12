taxdumpr
================
prata
Tue Dec 12 13:39:37 2017

``` r
knitr::opts_chunk$set(echo = TRUE)
```

**taxdumpr** is a R package which brings together a series of methods to manipulate NCBI's taxonomy data. It was developed to work locally, thorugh the NCBI's **taxdump** downloaded files. It was developed using the S4 class system.

**taxdump** files download
--------------------------

The **taxdump** files can be download from the NCBI's ftp site, at <ftp://ftp.ncbi.nih.gov/pub/taxonomy/>. You can download these files using **wget** with the command:

wget <ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz>

And uncompress it using **tar**:

tar zxvf <ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz>

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

``` r
devtools::install_github("felipepratalima/taxdumpr")
```

    ## Downloading GitHub repo felipepratalima/taxdumpr@master
    ## from URL https://api.github.com/repos/felipepratalima/taxdumpr/zipball/master

    ## Installation failed: Not Found (404)

Instantiate the **Taxdumpr** base class
---------------------------------------

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

1.  The getTaxonomyIdsByNames function should receive taxonomy name(s) and return taxonomy id(s):

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
