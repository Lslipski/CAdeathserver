#' nioccs_request
#' This function makes an API request for 1 combination of industry + occupation
#' @param i industry
#' @param o occupation
#' @param n number requested results per industy/occupation combination
#' @param c code type
#' @param v coding version
#' @param u unexpected result
#' @returns tibble
nioccs_request <- function(i,
                           o,
                           n,
                           c,
                           v,
                           u) {

  # Location of the NIOSH IO Coding service
  url <- "https://wwwn.cdc.gov/nioccs/IOCode"

  # Submit request
  response <- httr::GET(url,
                        query = list(i = tolower(i),
                                     o = tolower(o),
                                     n = paste0(n),
                                     c = paste0(c),
                                     v = paste0(v)))

  # check for errors and exit if found.
  if(httr::http_error(response)) {
    stop(paste0("API Request received an error.\n",
                "Industry: ",
                i,"\n",
                "Occupation: ",
                o,"\n"))
  } # close if


  content <- jsonlite::fromJSON(httr::content(response,
                                              as = "text"))

  content_tibble <- dplyr::bind_cols(content$Industry %>%
                                       dplyr::as_tibble(),
                                     content$Occupation %>%
                                       dplyr::as_tibble(),
                                     content$Scheme %>%
                                       dplyr::as_tibble()) %>%
    dplyr::mutate(mortality_industry = i,
                  mortality_occupation = o) %>%
    dplyr::relocate(mortality_industry,
                    mortality_occupation)

  return(content_tibble)
}




#' get_nioccs_ind_occ
#' @param df a tibble containing columns called 'industry' and 'occupation' corresponding to the text values of industry and occupation
#' @param number_results Number of candidates returned. The default is 1, returning the top industry and occupation code based on the probabilities from the auto-coder machine learning models.
#' @param return_code_types Flag that determines what type of codes to return. The default is 2. Options are: c=0 returns NAICS 2017/SOC 2018 codes; c=1 returns Census Industry and Occupation 2018 codes; c=2 returns both sets of codes (NAICS/SOC and corresponding Census I/O)
#' @param version Determines the coding scheme version returned.Default is 18. Options are: v=18 returns codes from CDC Census 2018/CDC NAICS 2017/CDC SOC 2018 coding scheme; v=12 returns codes from the CDC Census 2012/CDC NAICS 2012/CDC SOC 2010 coding schemes
#' @returns tibble containing the original occupation and industry plus all results from NIOCCS API
#' @export
#' @importFrom purrr map2
#' @examples
#' \dontrun{
#' df_mortality_occupation <- tribble(~industry, ~occupation,
#'                                    "HOSPITAL", "NURSE",
#'                                    "EDUCATION", "MEDIA DIRECTOR")
#' df_nioccs <- get_nioccs_ind_occ(df = df_mortality_occupation,
#'                                   number_results = 3)
#' }


get_nioccs_ind_occ <- function(df,
                               number_results = 1,
                               return_code_types = 2,
                               version = 18) {

  # map all rows to nioccs_request function
  data_list <- purrr::map2(.x = df$industry,
                           .y = df$occupation,
                           ~ nioccs_request(i = .x,
                                            o = .y,
                                            n = number_results,
                                            c = return_code_types,
                                            v = version)) %>%
    dplyr::bind_rows()

}
