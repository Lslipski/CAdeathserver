# Note, many of these functions came from Matt Kiang's code on excess drug overdoses
# using the CDC mortality data. (https://github.com/mkiang/excess_drug_overdoses/)

### FUNCTIONS RUN ON RAW MORTALITY FILES

#' recode_race
#' @param df a tibble containing raw mortality data
#'
#' @returns tibble same as input with new recoded race variable
#' @export
#' @examples
#' \dontrun{
#' df_with_clean_race <- df_raw %>%
#'                           recode_race()}
recode_race <- function(df) {
  df %>%
    dplyr::mutate(
      recode_race = dplyr::case_when(
        ## Being Hispanic trumps all other racial categorization rules
        hispanic.origin == "Y" ~ "Hispanic",
        ## Mixed, other, unknown.
        race.1.code.final != race.2.code.final ~ "Other",
        race.1.code.final != race.3.code.final ~ "Other",
        race.2.code.final != race.3.code.final ~ "Other",
        ## Then do single race
        race.1.code.final == 10 ~ "White",
        race.1.code.final == 20 ~ "Black",
        race.1.code.final %in% c(30, 57, 58) ~ "American Indian / Native American",
        race.1.code.final %in% c(41:49, 52:56, 59, 60:67) ~ "Asian / Pacific Islander",
        race.1.code.final %in% c(99, 51, 98) ~ "Other",
        ## Some rows missing everything
        is.na(race.1.code.final) &
          is.na(race.2.code.final) &
          is.na(race.3.code.final) ~ "Other",
        ## Search on this to make sure it's correct
        TRUE ~ "You missed a code if this label exists"
      )
    )
}


#' recode_facility_of_death
#'
#' @param df a tibble containing raw mortality data
#'
#' @returns tibble same as input with new recode_facility_of_death variable
#' @export
#'
#' @examples
#' \dontrun{
#' df_with_clean_race <- df_raw %>%
#'                           recode_facility_of_death()}
recode_facility_of_death <- function(df) {
  df %>% 
    dplyr::mutate(
      recode_facility_of_death = dplyr::case_when(place.of.death.facility == 1 ~ "Inpatient",
                                                  place.of.death.facility == 2 ~ "Emergency Room/Outpatient",
                                                  place.of.death.facility == 3 ~ "Dead on Arrival",
                                                  place.of.death.facility == 4 ~ "Decedent's Home",
                                                  place.of.death.facility == 5 ~ "Hospice Facility",
                                                  place.of.death.facility == 6 ~ "Nursing Home/Long Term Care Facility",
                                                  place.of.death.facility == 7 ~ "Other",
                                                  place.of.death.facility == 9 ~ "Unknown",
                                                  TRUE ~ "You missed a code if this label exists")
    )
}


#' recode_marital_status
#'
#' @param df a tibble containing raw mortality data with variable `marital.status`
#'
#' @returns identical tibble with new variable `recode_marital_status`
#' @export
#'
#' @examples
#' \dontrun{
#' df_with_clean_marital_status <- df_raw %>%
#'                                       recode_marital_status()}
recode_marital_status <- function(df) {
  df %>% 
    dplyr::mutate(
      recode_marital_status = dplyr::case_when(
        # Married
        marital.status %in% c("M", "P", "X", "Y") ~ "Married/Partnered",
        # Widowed 
        marital.status %in% c("W", "V") ~ "Widowed",
        # Divorced 
        marital.status == "D" ~ "Divorced",
        # Never Married
        marital.status == "S" ~ "Never Married",
        # Unknown
        marital.status == "U" ~ "Unknown",
        # All other
        TRUE ~ "You missed a code if this label exists"
      )
    )
}


#' recode_age
#' @param df a tibble containing raw mortality data
#' @returns tibble same as input with new variable age_int which is numeric age
#' @export
#' @examples
#' \dontrun{
#' df_raw_with_int_age <- df_raw %>%
#'                           recode_age()}
recode_age <- function(df) {
  df <- df %>%
    dplyr::mutate(recode_age_int = as.integer(age.in.years))
}

#' recode_education_standard
#' @param df a tibble containing raw mortality data
#' @returns tibble same as input with new recoded education variable `recode_educ_standard`
#' @export
#' @examples
#' \dontrun{
#' df_raw_with_clean_educ <- df_raw %>%
#'                             recode_education()}
recode_education_standard <- function(df) {
  df %>%
    dplyr::mutate(age_int = as.integer(age.in.years)) %>%
    dplyr::mutate(
      recode_educ_standard = dplyr::case_when(
        age_int < 25 ~ "under25",
        education.degree.nchs %in% 1:2 ~ "< hs",
        education.degree.nchs == 3 ~ "hs",
        education.degree.nchs %in% 4:5 ~ "< bs",
        education.degree.nchs == 6 ~ "bs",
        education.degree.nchs %in% 7:8 ~ ">bs",
        TRUE ~ "unknown edu"
      )
    ) %>%
    dplyr::select(-age_int)
}

#' recode_education_farmworkers
#' @param df a tibble containing raw mortality data
#' @returns tibble same as input with new recoded education variable `recode_educ_farmwork`
#' @export
#' @examples
#' \dontrun{
#' df_raw_with_clean_educ <- df_raw %>%
#'                             recode_education_farmworkers()}
recode_education_farmworkers <- function(df) {
  df %>%
    dplyr::mutate(
      recode_educ_farmwork = dplyr::case_when(
        education.degree.nchs == 1 ~ "1. 8th grade or less",
        education.degree.nchs == 2 ~ "2. 9th through 12th grade; no diploma",
        education.degree.nchs == 3 ~ "3. High School Graduate or GED Completed",
        education.degree.nchs %in% 4:8 ~ "4. More than High School or GED",
        education.degree.nchs == 9 | is.na(education.degree.nchs) ~ "5. Unknown",
        TRUE ~ "You missed a code if this label exists"
      )
    ) 
}

#' recode_sex
#' @param df a tibble containing raw mortality data
#' @returns tibble same as input with new recoded sex variable
#' @export
#' @examples
#' \dontrun{
#' df_raw_with_clean_sex <- df_raw %>%
#'                           recode_sex()}
recode_sex <- function(df) {
  df %>%
    dplyr::mutate(
      recode_sex = dplyr::case_when(sex == "F" ~ "female",
                                    sex == "M" ~ "male",
                                    TRUE ~ NA_character_)
    )
}

#' min_data
#' Remove unnecessary (potentially identifying) columns
#' @param df a tibble containing raw mortality data
#'
#' @returns tibble same as input with possibly identifying columns removed
#' @export
#' @examples
#' \dontrun{
#' df_deidentified <- df_raw %>%
#'                       min_data()}
min_data <- function(df) {
  df %>%
    dplyr::select(
      id,
      recode_race,
      recode_educ,
      age = recode_age_int,
      sex = recode_sex,
      dod = date.of.death,
      state_name = residence.state.province,
      county_name = county.of.residence.geocode.text,
      county_fip = final.county.of.residence.geocode.nchs,
      county_cdph = final.county.of.residence.geocode.cdph,
      ucod = final.cause.of.death.icd10,
      dplyr::starts_with("record.axis.code")
    )

  ## Clean up a little bit and unite contributory causes ----
  min_data <- min_data %>%
    tidyr::unite(record_all,
                 dplyr::starts_with("record.axis.code"),
                 sep = " ") %>%
    dplyr::mutate(ucod = trimws(ucod),
                  record_all = trimws(gsub(
                    pattern = " NA", replacement = "", record_all
                  ))) %>%
    dplyr::select(-dplyr::starts_with("record.axis.code"))
}



#' subset_death_date
#' Limits to records before or after (or both) certain dates (in yyyy-mm-dd format).
#' Note that for excess mortality and other algorithms, you might want to choose nearest sundays.
#' @param df a tibble containing raw mortality data (including variable date.of.death)
#' @param before_date a string specifying a yyyy-mm-dddate. Only records with a date of death on or before this date will be kept.
#' @param after_date a string specifying a yyyy-mm-dd date. Only records with a date of death on or after this date will be kept.
#' @param remove_dod_na boolean where if False (default) does nothing. If True removes records where the date.of.death is NA
#' @returns tibble same columns as input with rows filtered on death dates provided
#' @export
#' @examples
#' \dontrun{
#' df_deidentified <- df_raw %>%
#'                       subset_death_date(before_date = "2023-08-31",
#'                                         after_date = "2019-06-21")}
subset_death_date <- function(df,
                     before_date = "",
                     after_date = "",
                     remove_dod_na = F) {

  if (before_date != "" &
      after_date != "") {
    this_df <- df %>%
      dplyr::filter(date.of.death <= as.Date(before_date),
                    date.of.death >= as.Date(after_date))
  } else if (before_date != "") {
    this_df <- df %>%
      dplyr::filter(date.of.death <= as.Date(before_date))
  } else if (after_date != "") {
    this_df <- df %>%
      dplyr::filter(date.of.death >= as.Date(after_date))
  } else {
    this_df <- df
    warning("Function subset_death_date did not find a valid before or after date in yyyy-mm-dd format.")
  }

  if (isTRUE(remove_dod_na)) {
    this_df <- this_df %>%
      dplyr::filter(!is.na(date.of.death))
  }

  return(this_df)
}


#' create_covid_death_flag
#'
#' @description
#' Uses all record.axis.code variables and the final.cause.of.death.icd variable to create a 1/0
#' flag where 1 means the death was due to covid. This code was taken from Matt Kiang's repo
#' here: https://github.com/mkiang/excess_drug_overdoses/blob/main/code/01_ingest_death_data.R
#'
#' @param df a tibble including the all record.axis.code variables and the final.cause.of.death.icd variable
#' from the raw death data
#' @param ucod_only Boolean determining whether to use only the underlying cause of death code ICD-10
#' or to use all available cause of death codes in the record.axis.code fields. TRUE means only
#' the underlying COD is used. Default is FALSE.
#'
#' @returns tibble identical to input but with 1/0 covid_death flag
#' @export
#'
#' @examples \dontrun{df_covid_deaths_only = df %>%
#'                                         create_covid_death_flag() %>%
#'                                         filter(covid_death == 1)}
create_covid_death_flag <- function(df,
                                    ucod_only = FALSE) {

  cleaned_df <- df %>%
    tidyr::unite(record_all,
                 dplyr::starts_with("record.axis.code"),
                 sep = " ") %>%
    dplyr::mutate(ucod = trimws(final.cause.of.death.icd10),
                  record_all = trimws(gsub(pattern = " NA",
                                           replacement = "",
                                           record_all)))


  if (ucod_only) {
    cleaned_df <- cleaned_df %>%
      dplyr::mutate(covid_death = grepl("\\<U071", ucod) + 0) %>%
      dplyr::select(-ucod,
                    -record_all)
  } else {
    cleaned_df <- cleaned_df %>%
      dplyr::mutate(covid_death = grepl("\\<U071", record_all) + 0) %>%
      dplyr::select(-ucod,
                    -record_all)
  }

  return(cleaned_df)

}





#' get_ca_region
#' Joins a tibble that contains `county.of.death.code` as an integer with no leading zeroes
#' and joins to `ca_regions_fips` return the same tibble with additional variables:
#'  - `region` (number)
#'  - `region_name`
#'  - `county_name` (camel case)
#'  - `county_fips`
#'  - `county_cdph`
#'
#' @param df a tibble containing the variable `county.of.death.code` from the california death
#' data as an integer with no leading zeroes
#'
#' @importFrom stringr str_remove
#'
#' @returns tibble same as input with additional region and county info
#' @export
#'
#' @examples \dontrun{df_cleaned_county <- df %>%
#'                                           get_ca_region()}
get_ca_region <- function(df) {

  df %>%
    dplyr::left_join(load("data/ca_regions_fips.rda") %>%
                       dplyr::mutate(join_cdph_code = as.integer(stringr::str_remove(county_cdph,
                                                              "^0+"))),
                     by = c("county.of.death.code" = "join_cdph_code"))
}




### FUNCTIONS RUN ON CLEANED MORTALITY FILE

#' get_ca_only
#'
#' @param df a cleaned version of the raw mortality file that includes the variable state_name
#'
#' @returns tibble same as input df but with only rows where residence.state.province is california
#' @export
#'
#' @examples
#' \dontrun{
#' df_clean_ca <- df_clean %>%
#'                 get_ca_only()}
get_ca_residence_only <- function(df) {
  df %>%
    dplyr::filter(residence.state.province == "CA") %>%
    dplyr::select(-residence.state.province)
}


