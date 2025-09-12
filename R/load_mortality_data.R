#' load_ca_mortality_data
#'
#' @param df a string specifying a specific mortality data set filename or latest (defaut)
#'
#' @importFrom dplyr  %>%
#' @importFrom dplyr  slice
#' @importFrom dplyr  tibble
#' @returns tibble
#' @export
#'
#' @examples \dontrun{
#'   df_mortality_2022 <- load_ca_mortality_data(df = '2021-12-31')
#'   df_mortality_latest <- load_ca_mortality_data()
#' }
load_ca_mortality_data <- function(df = 'latest') {

  this_path = 'E:/data us ca/locked'

  if(df == 'latest') {
    mortality_file <- list.files(path = this_path,
                                 pattern = "data.*\\.rds",
                                 full.names = TRUE) %>%
      sort(decreasing = TRUE)
    mortality_file <- mortality_file[[1]]

    writeLines(paste0("Pulling: ",
                      mortality_file))

    df_mortality <- readRDS(mortality_file) %>%
      dplyr::tibble()

  }
  else {
    writeLines(paste0("Pulling: ",
                      this_path,
                      df))

    df_mortality = readRDS(file = paste0(this_path,
                                         "/data ",
                                         df,
                                         ".rds")) %>%
      dplyr::tibble()

  }

  return(df_mortality)

}
