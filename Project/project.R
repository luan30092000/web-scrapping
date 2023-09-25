# Load libraries
library(tidyverse)    # general purpose data wrangling
library(rvest)        # parsing of HTML/XML file
library(stringr)      # string manipulation
# library(rebus)        # verbose regular expression
library(lubridate)    # Datetime manipulation

# Scrapping website
url <- "https://ca.trustpilot.com/review/www.apple.com"

# Program outline
# 1. Find maximum number of pages to be queried
# 2. Generate all sub-webpages that make up the review
# 3. Scrape the information from each of the page 
# 4. Combine the information into one comprehensive data frame

# 1. Find the maximum number of pages
get_last_page <- function(html) {
  pages_data <- html %>% 
    html_nodes(".pagination-link_item__mkuN3") %>%
    html_text()
  # The second to last of the button is the one
  pages_data[length(pages_data)] %>% 
    unname() %>%
    as.numeric()
}
first_page <- read_html(url)
last_page <- get_last_page(first_page)

# 2. Generate all sub-webpages that make up the review
list_of_pages <- str_c(url, '?page=', 1:last_page)


# 3. Scrape the information from each of the page

get_review_comment <- function(html) {
  html %>%
    html_nodes('.link_notUnderlined__szqki .typography_appearance-default__AAY17') %>% 
    html_text() %>%
    str_trim()
}

get_review_name <- function(html) {
  html %>% 
    html_nodes('.styles_consumerDetails__ZFieb .typography_appearance-default__AAY17') %>%
    html_text() %>%
    str_trim()
}

get_review_rate <- function(html) {
  html %>%
    html_nodes('.styles_reviewHeader__iU9Px img') %>%
    html_attrs() %>%
    map(1) %>%
    unlist() %>%
    str_trim() %>%
    str_extract("(?<=Rated ).(?= out)")
}

get_review_date <- function(html) {
  html %>%
    html_nodes('.typography_body-m__xgxZ_.typography_color-black__5LYEn') %>%
    html_text() %>%
    str_match("(?<=experience: ).*$") %>%
    mdy()
}

# Get review data from a specific page
get_data_table <- function(html, companyName) {
  html <- read_html(html)
  comment <- get_review_comment(html)
  reviewer <- get_review_name(html)
  date <- get_review_date(html)
  rate <- get_review_rate(html)
  reviewTibble <- tibble(comment = comment, 
                         reviewer = reviewer, 
                         date = date, 
                         rate = rate)
  reviewTibble <- reviewTibble %>% 
    mutate(company = companyName) %>%
    select(company, reviewer, date, rate, comment)
}
  
scrape_write_table <- function(url, companyName) {
  first_page = read_html(url)
  last_page_number = get_last_page(first_page)
  list_of_pages <- str_c(url, '?page=', 1:last_page_number)
  dataTibble <- NULL
  for(i in 1:length(list_of_pages)) {
    data <- get_data_table(list_of_pages[i], companyName)
    dataTibble <- bind_rows(dataTibble, data)
  }
  return(dataTibble)
}
data <- scrape_write_table(url, "APPLE")
write.csv(data, file = "appleReview.csv")
