# This function showcases how one might write a function to be used as an
# RStudio project template. This function will be called when the user invokes
# the New Project wizard using the project template defined in the template file
# at:
#
#   inst/rstudio/templates/project/make_qtw_template.dcf
#
# The function itself just echos its inputs and outputs to a file called INDEX,
# which is then opened by RStudio when the new project is opened.
make_qtw_template <- function(path, ...) {

  # ensure path exists
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

  # collect inputs
  # the inputs link to Parameter inside make_qtw_template.dcf
  dots <- list(...)

  # select template ----
  # check arguments
  if(dots[["template_option"]] == "Minimal"){
    template <- "template_minimal"

  }else if(dots[["template_option"]] == "Standard"){
    template <- "template_standard"

  }else if(dots[["template_option"]] == "Course"){
    template <- "template_course"

  }else{
    stop("Template does not exist")
  }

  # system.file("R", "hello.R", package = 'qtwAcademic')
  template_path <- system.file(template, package = 'qtwAcademic')

  # collect into single text string
  # contents <- paste(
  #   paste(header, collapse = "\n"),
  #   paste(text, collapse = "\n"),
  #   sep = "\n"
  # )

  # write to index file
  # writeLines(contents, con = file.path(path, "INDEX"))


  # could be useful to include where to put navigation bar

  # copy files to root dir ----
  # template 1: minimal
  # yml
  file.copy(from = paste0(template_path, "/", "_quarto.yml"),
            to = file.path(path, "_quarto.yml"))

  # index
  file.copy(from = paste0(template_path, "/", "index.qmd"),
            to = file.path(path, "index.qmd"))

  # about
  file.copy(from = paste0(template_path, "/", "about.qmd"),
            to = file.path(path, "about.qmd"))

  # # style
  file.copy(from = paste0(template_path, "/", "styles.css"),
            to = file.path(path, "styles.css"))



  # template 2: standard (maybe add one extended)



  # template 3: course
  if(template == "template_course"){
    # copy part 1, part 2 and data
    file.copy(from = paste0(template_path, "/", "part_1_prep.qmd"),
              to = file.path(path, "part_1_prep.qmd"))

    file.copy(from = paste0(template_path, "/", "part_2_eda.qmd"),
              to = file.path(path, "part_2_eda.qmd"))

    dir.create(file.path(path, "data"),
               recursive = T, showWarnings = F)
    file.copy(from = paste0(template_path, "/", "data/data_example.txt"),
              to = file.path(path, "data/data_example.txt"))

  }



}
