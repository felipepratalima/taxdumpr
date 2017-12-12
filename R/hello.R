# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

hello <- function() {
  print("Hello, world!")
}

# duplicados <- which(duplicated(myNames$name))
# duplicadoNomes <- unique(myNames[duplicados,]$name)
# for (i in 1:length(duplicadoNomes)) {
#   duplicadoNome <- duplicadoNomes[i]
#   contagem <- length(unique(myNames[myNames$name == duplicadoNome,]$id))
#   if (contagem > 1) print(duplicadoNome)
# }
