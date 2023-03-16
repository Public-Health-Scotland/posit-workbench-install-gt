################################################################################
# Name of file:       install_and_test_gt.R
# Type of script:     R
#
# Written/run on: R version 4.1.2 (2021-11-01) -- "Bird Hippie"
# Platform: x86_64-pc-linux-gnu (64-bit)
#
# Install and test the {gt} package
################################################################################

### 00 - Install {gt} ----

# Recursively search for {gt}'s dependencies and their dependencies and so on.
# Obtain a unique list of these dependencies and install them.'
gt_deps <- unique(unlist(tools::package_dependencies(packages = c("gt"), recursive = TRUE)))
install.packages(gt_deps)

# {checkmate} and {webshot} are missed as a dependency and suggestion
# respectively, as {gt} v0.7.0 no longer uses them.  However, we are going to
# install {gt} v0.5.0 which needs both of those packages.
install.packages(c("checkmate", "webshot"))

# Install {gt} v0.5.0 from source
install.packages(
  "https://ppm.publichealthscotland.org/all-r/latest/src/contrib/Archive/gt/gt_0.5.0.tar.gz",
  repos = NULL)
 
# {gt} makes use of the {webshot} package to take screenshots of web pages from R.
# It requires an installation of the external program PhantomJS. The following
# code installs PhantomJS v2.1.1 in ~/bin

phantomjs_archive_name <- "phantomjs-2.1.1-linux-x86_64"
phantomjs_archive_filename <- paste0(phantomjs_archive_name, ".tar.bz2")
phantomjs_archive_url <- paste("https://github.com/wch/webshot/releases/download/v0.3.1",
                               phantomjs_archive_filename,
                               sep="/")

system(paste0("cd ~/; wget ", phantomjs_archive_url)) # Download the PhantomJS archive
system(paste0("cd ~/; tar -xf ", phantomjs_archive_filename)) # Uncompress the archive
system("mkdir -p ~/bin") # Create the ~/bin directory, if it doesn't exist
system(paste0("cd ~/; mv ", phantomjs_archive_name, "/bin/phantomjs ~/bin/")) # Move the PhantomJS binary to ~/bin
system(paste0("rm -rf ~/", phantomjs_archive_name)) # Delete the directory containng the contents of the archive
system(paste0("rm ~/", phantomjs_archive_filename)) # Delete the archive itself

# Make sure that ~/bin exists somewhere in the environment variable PATH.
# This is required so that {webshot} can find PhantomJS.
old_path <- Sys.getenv("PATH")
if(!(grepl(path.expand("~/bin"), old_path))){
  Sys.setenv(PATH = paste(old_path, path.expand("~/bin"), sep = ":"))
}

### 01 - Test {gt} ----

library(gt)
library(dplyr)
library(glue)

# Define the start and end dates for the data range
start_date <- "2010-06-07"
end_date <- "2010-06-14"
 
# Create a {gt} table based on preprocessed `sp500` table data
gt_table <- sp500 |>
 filter(date >= start_date & date <= end_date) |>
 select(-adj_close) |>
 gt() |>
 tab_header(
   title = "S&P 500",
   subtitle = glue("{start_date} to {end_date}")
 ) |>
 fmt_date(
   columns = date,
   date_style = 3
 ) |>
 fmt_currency(
   columns = c(open, high, low, close),
   currency = "USD"
 ) |>
 fmt_number(
   columns = volume,
   suffixing = TRUE
 )

# Save the table as a PNG
gt::gtsave(gt_table, filename = "tmp.png")
