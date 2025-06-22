# ==============================================================================
# Packages & functions for global MPA effectiveness analysis 
# Ella Clausius
# March 2025
# ==============================================================================

select <- dplyr::select
summarise <- dplyr::summarise
rename <- dplyr::rename 


using <- function(...) {
  libs <- unlist(list(...))
  req <- unlist(lapply(libs, require, character.only = TRUE))
  need <- libs[req == FALSE]
  if (length(need) > 0) {
    install.packages(need)
    lapply(need, require, character.only = TRUE)
  }
}


# install.packages("devtools")
# devtools::install_github("bio-oracle/biooracler")

# packages required for the analysis
using("tidyverse", 
      "janitor", 
      "lubridate",
      "sf", 
      "terra", 
      "biooracler", 
      "future", 
      "tictoc", 
      "purrr", 
      "vip", 
      "tune", 
      "ggplot2", 
      "knitr", 
      "parsnip", 
      "workflows",
      "rsample", 
      "caret", 
      "DALEXtra", 
      "recipes", 
      "dials", 
      "randomForest", 
      "ranger", 
      "patchwork",
      "furrr",
      "RColorBrewer",
      "viridis",
      "vroom", 
      "progressr", 
      "giscoR", 
      "SpatialML", 
      "future")

# Negate 
`%!in%` = Negate(`%in%`)