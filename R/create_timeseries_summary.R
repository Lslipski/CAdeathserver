#' compute_weekly_deaths
#'
#' @param .df a tibble containing the variable date.of.death
#' @param ... additional variables by which the weekly data should be grouped
#' @param .include_covid TRUE/FALSE (default TRUE) flag indicating whether to create a column specifically counting covid deaths
#'
#' @returns a tibble containing the week of death, all grouping columns, and a count of deaths (and, optionally, an additional covid death count). Note that the week of death will be returned as a Date, and all grouping variables will be returned as factors.
#'
#' @importFrom dplyr mutate
#' @importFrom dplyr select
#' @importFrom dplyr filter
#' @importFrom dplyr across
#' @importFrom dplyr summarize
#'
#' @export
#'
#' @examples \dontrun{df_weekly_by_sex <- my_df %>%
#'                                             compute_weekly_deaths(.df = .,
#'                                                                   sex)}
compute_weekly_deaths <- function(.df,
                               ...,
                               .include_covid = FALSE) {

  .df %>%
    # optionally create covid flag
    {if(.include_covid == TRUE) create_covid_death_flag(.)
      else .} %>%
    # select id, dod, covid flag (optional), and any supplied grouping variables
    dplyr::select(.,
                  id,
                  date.of.death,
                  dplyr::any_of("covid_death"), # select covid flag only if it exists
                  ...) %>%
    # limit to existing DODs
    dplyr::filter(!is.na(date.of.death)) %>%
    # assign all dods to a week
    # note that all week days will be Saturday
    dplyr::mutate(week = date.of.death + (6 - as.numeric(format(date.of.death,'%w'))),
                  death = 1) %>%
    dplyr::mutate(dplyr::across(.cols = c("week",
                                   ...),
                         .fns = as.factor)) %>%
    # group by week and any grouping variables within that week, preserving empty groups
    dplyr::group_by(week,
             ...,
             .drop = FALSE) %>%
    {if(.include_covid == TRUE) dplyr::summarize(.,
                                                 deaths = sum(death),
                                                 covid_deaths = sum(covid_death),
                                                 .groups = "drop")
      else dplyr::summarize(.,
                            deaths = sum(death),
                            .groups = "drop")} %>%
    dplyr::mutate(week = as.Date(week))

}



#' compute_monthly_deaths
#'
#' @param .df a tibble containing the variable date.of.death
#' @param ... additional variables by which the monthly data should be grouped
#' @param .include_covid TRUE/FALSE (default TRUE) flag indicating whether to create a column specifically counting covid deaths
#'
#' @returns a tibble containing the month of death, all grouping columns, and a count of deaths (and, optionally, an additional covid death count). Note that the month of death will be returned as a Date and all grouping variables will be returned as factors.
#' @export
#'
#' @examples \dontrun{df_monthly_by_sex <- my_df %>%
#'                                             compute_monthly_deaths(.df = .,
#'                                                                          sex)}
compute_monthly_deaths <- function(.df,
                                  ...,
                                  .include_covid = FALSE) {

  .df %>%
    # optionally create covid flag
    {if(.include_covid == TRUE) create_covid_death_flag(.)
      else .} %>%
    # select id, dod, covid flag (optional), and any supplied grouping variables
    dplyr::select(.,
                  id,
                  date.of.death,
                  dplyr::any_of("covid_death"), # select covid flag only if it exists
                  ...) %>%
    # limit to existing DODs
    dplyr::filter(!is.na(date.of.death)) %>%
    # assign all dods to a month
    dplyr::mutate(month = substr(date.of.death, 1, 7),
                  death = 1) %>%
    dplyr::mutate(dplyr::across(.cols = c("month",
                                          ...),
                                .fns = as.factor)) %>%
    # group by month and any grouping variables within that month, preserving empty groups
    dplyr::group_by(month,
                    ...,
                    .drop = FALSE) %>%
    {if(.include_covid == TRUE) dplyr::summarize(.,
                                                 deaths = sum(death),
                                                 covid_deaths = sum(covid_death),
                                                 .groups = "drop")
      else dplyr::summarize(.,
                            deaths = sum(death),
                            .groups = "drop")} %>%
    dplyr::mutate(month = as.Date(paste(month,'01',sep='-'),'%Y-%m-%d'))

}
