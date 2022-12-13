#' @import data.table ggplot2
#' @importFrom magrittr %>%
.onAttach <- function(libname, pkgname) {
    version <- tryCatch(
      utils::packageDescription("PACKAGE", fields = "Version"),
      warning = function(w){
        1
      }
    )
  
  packageStartupMessage(paste0(
    "PACKAGE ",
    version,
    "\n",
    "https://docs.sykdomspulsen.no/PACKAGE/"
  ))
}
