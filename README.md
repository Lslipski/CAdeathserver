
<!-- README.md is generated from README.Rmd. Please edit that file -->

# CAdeathserver

This repository contains code for analyzing CA death data on the PEARL
server using the r programming language. Yea-Hung is the admin for this
data, and most of the important code in this package was developed by
him.

## Installation

To load the functions in this package, first install the package using
`remotes` (more details below). Then load with:

``` r
library('CAdeathserver')
```

If you get caught up on the below steps, you can reach out to Luke
Slipski.

### Details

The package is not yet available from common CRAN repositories, so it
must be installed directly from github. Here are some relevant links:

- [Package Code](https://github.com/aliciarr/CAdeathserver/tree/main)
- [Documentation](https://cran.r-project.org/web/packages/remotes/readme/README.html)
  on using remotes package to install non-CRAN packages

**First**, set up a connection to github using your github account. This
should only need to be done the first time you install the CAdeathserver
package from its non-CRAN github repo and any time the package has
subsequent updates.

**NOTE:** This will involve a few steps that require you have a github
account.

1.  Log in to Github on the VM in the browser using your
    username/password

2.  Create a git PAT for this VM and add it to the R credentials (more
    documentation on this [here](https://happygitwithr.com/https-pat)
    and the relevant lines of code are below).

Run these lines to do \#2 (you might need to first run
`install.packages('usethis', 'remotes', 'gitcreds')`)

``` r
library('remotes')
library('usethis')
library('gitcreds')
```

``` r
usethis::create_github_token()
```

When `create_github_token()` runs, it will open github in your browser.
Generally, the default scopes are sufficient. Press “Generate token” and
leave that window open. Now run:

``` r
gitcreds::gitcreds_set()
```

From your open github browser window, copy and paste your new PAT from
your browser into the Rstudio console. Hit enter, and your PAT will be
successfully saved. You should now be able to install the
`CAdeathserver` package.

3.  Install the CAdeathserver (this may take a minute to run on the VM)

Run the following to install the `CAdeathserver` package from the remote
github location:

``` r
remotes::install_git("https://github.com/aliciarr/CAdeathserver")
```

The package should now be installed. To load in your Rstudio session
run:

``` r
library('CAdeathserver')
```

## Common Data Pipeline

Projects using data tend to follow a similar processing pipeline:

**Server-Side Processing**

1.  Death data is stored on the server in data files that have
    person-level death certificate information. This level data must
    stay on the secure server.

2.  Because only aggregate data can leave the server, the person-level
    data must be stratified into groups of interest and then counted in
    some way, usually across weekly or monthly intervals. Therefore, the
    usual data output moved from the server for analysis is a table
    where each row is a period of time (e.g. one week), each column is a
    specific group of interest (e.g. “Overall”), and each cell in the
    table is a count of people who died in a given group during a given
    time period. This output has historically saved as
    `weekly data.rds`. See `compute_weekly_deaths()` and
    `compute_monthly_deaths()` to create this file.

**Non-Server Processing**

1.  Once `weekly data.rds` has been produced, it can be moved off-server
    and utilized for various analyses. One common analysis is *excess
    mortality* using ARIMA models – the code for which was developed by
    Yea-Hung. This code uses pre-pandemic mortality data to provide an
    estimate of expected mortality during the pandemic period. The
    observed mortality can then be compared to the expected mortality to
    provide an estimate of excess mortality.

2.  If estimates of population size by group are computed, per capita
    rates can also be computed using ACS data. This functionality coming
    soon.

## Functions

This package provides the following functions for use in the above data
pipeline:

### Data Wrangling

- `prepare_groups()` – Defines the groups by which to stratify the death
  data. Returns…
- `to_weeks()` – Takes the groups defined by `prepare_groups()` and
  counts the number of deaths per week within those groups. Returns…
- `produce_weekly_data()` – Uses the output from `prepare_groups()` and
  `to_weeks()` to produce the desired `weekly_data.rds` file. Returns a
  tibble of this data, which can be exported from the server for
  analysis.
- `estimate_weekly_excess()` – Uses a single column (e.g. counts of
  deaths from one group by week) in `weekly_data.rds` to estimate
  pandemic mortality based on pre-pandemic mortality. Returns a data
  object with tabular estimates of excess as well as a plot of both
  observed and expected mortality.

### Utility Functions

- `load_mortality_data()` – Loads the latest available death certificate
  data available on the server or a specified historical death
  certificate data set.

## Data

This package also includes small utility datasets that are useful for
working with California data. These include:

- `ca_regions_fips` – Contains California regions names and numbers, as
  well as county names with their respective Federal Information
  Processing Standard (FIPS) codes and California Department of Public
  Health (CDPH) codes.
