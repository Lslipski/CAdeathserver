#' load_industry_occupation
#'
#' @description
#' Convenience function for loading the industry and occupation code data associated with the 2023-08-31 mortality data file.
#' Matched codes from NIOCCS were pulled on March 28, 2025.
#'
#'
#' @returns tibble containing all distinct industry + occupation combinations from the 2023-08-31 mortality file
#' and their matched census, naics, and soc codes/titles where possible through the NIOCCS matching online tool.
#'
#' @importFrom readr read_rds
#' @export
#'
#' @examples
#' \dontrun{df_ind_occ <- load_industry_occupation()}
load_industry_occupation <- function() {

  this_path = 'E:/shared/heb_lab/data/nioccs/nioccs_coded_ind_occ_20230831_mortality.rds'

  readr::read_rds(file = this_path)
}



#' @title join_industry_occupation
#'
#' @description This function takes a tibble from the mortality data (must include `industry` and `occupation` varaibles)
#' and joins NIOCCS-derived industry and occupation data.
#'
#' @param df to match industry/occupation data to. Must contain variables `industry` and `occupation`.
#' See NIOCCS documentation for variable descriptions https://csams.cdc.gov/nioccs/HelpOutput.aspx
#'
#'  - census_ind_code
#'  - census_ind_title
#'  - census_occ_code
#'  - census_occ_title
#'  - naics_code
#'  - naics_title
#'  - naics_probability
#'  - soc_code
#'  - soc_title
#'  - soc_probability
#'  - unexpected_naics_soc_combo
#' @returns tibble identical to input data plus 11 new variables:
#'
#' @importFrom dplyr left_join
#' @export
#'
#' @examples \dontrun{
#' my_df_with_ind_occ <- join_industry_occupation(my_df)}
join_industry_occupation <- function(df) {

  df_ind_occ <- load_industry_occupation()

  df_matched <- df %>%
    dplyr::left_join(df_ind_occ,
              by = c("industry" = "mortality_industry",
                     "occupation" = "mortality_occupation")) %>% 
    # cleaning up because industry_occupation and mortality data both have an id column
    dplyr::rename(id = id.x) %>% 
    dplyr::select(-id.y)

  return(df_matched)

}









