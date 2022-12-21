#' Make Quarto Website template
#'
#' @description This function makes an R project that includes 3 basic templates
#' that are commonly used by academics.
#'
#' @param path Path of the R project
#' @param template_option Template option to choose.
#' @return Returns nothing.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   make_qtw_template(path = tempdir(), template_option = "Minimal")
#' }

make_qtw_template <- function(path, template_option) {

  # ensure path exists
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

  # collect inputs
  # the inputs link to Parameter inside make_qtw_template.dcf
  # dots <- list(...)

  # select template ----
  # check arguments
  if(template_option == "Minimal"){
    template <- "template_minimal"

  }else if(template_option == "Personal"){
    template <- "template_personal"

  }else if(template_option == "Course"){
    template <- "template_course"

  }else{
    stop("Template does not exist")
  }

  # if(dots[["template_option"]] == "Minimal"){
  #   template <- "template_minimal"
  #
  # }else if(dots[["template_option"]] == "Personal"){
  #   template <- "template_personal"
  #
  # }else if(dots[["template_option"]] == "Course"){
  #   template <- "template_course"
  #
  # }else{
  #   stop("Template does not exist")
  # }

  # dots <- list()
  # dots[["template_option"]] <- "Personal (top navigation)"
  # system.file("R", "onAttach.R", package = 'qtwAcademic')
  # template <- "template_minimal"
  # template <- "template_standard"
  # template <- "template_course"
  template_path <- system.file(template, package = 'qtwAcademic')

  # copy template content to the new project
  # ps <- "/Users/andrea/Documents/GitHub"
  # dir.create(file.path(ps, "TT"), recursive = T, showWarnings = F)
  # path <- file.path(ps, "TT")



  # write to index file
  # writeLines(contents, con = file.path(path, "INDEX"))
  # could be useful to include where to put navigation bar


  # copy files to root dir ---- #
  # index, about, style, gitignore ----
  # index
  file.copy(from = file.path(template_path, "index.qmd"),
            to = file.path(path, "index.qmd"))

  # about
  file.copy(from = file.path(template_path, "about.qmd"),
            to = file.path(path, "about.qmd"))

  # style
  file.copy(from = file.path(template_path, "styles.css"),
            to = file.path(path, "styles.css"))

  # yml
  file.copy(from = file.path(template_path, "_quarto.yml"),
            to = file.path(path, "_quarto.yml"))

  # config files
  # gitignore
  file.copy(from = file.path(template_path, ".gitignore"),
            to = file.path(path, ".gitignore"))



  # personal web only ----
  # profile that are specific for personal websites
  if(template %in% c("template_minimal", "template_personal")){
    file.copy(from = file.path(template_path, "profile.png"),
              to = file.path(path, "profile.png"))

    # for directories, copy the whole dir
    # use fs::dir_copy can avoid creating new dir
    # projects
    fs::dir_copy(file.path(template_path, "projects"),
                 file.path(path, "projects"))

    if(template != "template_minimal"){

      # talks
      fs::dir_copy(file.path(template_path, "talks"),
                   file.path(path, "talks"))

      # blogs
      file.copy(from = file.path(template_path, "blog.qmd"),
                to = file.path(path, "blog.qmd"))
      fs::dir_copy(file.path(template_path, "blog"),
                   file.path(path, "blog"))

      # additional about_template
      file.copy(from = file.path(template_path, "about_template.qmd"),
                to = file.path(path, "about_template.qmd"))

    }

  }



  # course/workshop only ----
  # template 3: course
  if(template == "template_course"){
    # copy part 1, part 2 and data
    file.copy(from = file.path(template_path, "part_1_prep.qmd"),
              to = file.path(path, "part_1_prep.qmd"))

    file.copy(from = file.path(template_path, "part_2_eda.qmd"),
              to = file.path(path, "part_2_eda.qmd"))

    # data
    fs::dir_copy(file.path(template_path, "data"),
                 file.path(path, "data"))

  }

}
