#' @import data.table ggplot2
#' @importFrom magrittr %>%
.onAttach <- function(libname, pkgname) {
    version <- tryCatch(
      utils::packageDescription("qtwAcademic", fields = "Version"),
      warning = function(w){
        1
      }
    )

  packageStartupMessage(paste0(
    "qtwAcademic ",
    version
  ))
}
