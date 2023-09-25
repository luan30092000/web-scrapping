# STAT260 - Web Scrapping Project

## Requirement:
Because every website have a different build structure, in this particular report, we will scrap data from [Trustpilot](https://ca.trustpilot.com/review/www.apple.com)
Quick knowledge about HTML, each HTML element will be associated with a class, id, element tag,. . . So we will use those to distinct and extract the element that we want.
To be more efficient, we will use element selector gadget, you can read more about the usage instruction in the website.
We will also use these R packages: tidyverse, rvest, stringr, lubridate. Detail of the packages is in the below

## Outline steps:
1. Find the number of the last page
2. Generate a vector that store all the pages
3. Scrap data from each of the sub-webpage from the vector
4. Combine the data into a single comprehensive data frame

## Scrapping
Install the package if needed
```R
# install.packages("tidyverse") # install.packages("rvest")
# install.packages("stringr")
# install.packages("lubridate") library(tidyverse) library(dplyr)
library(rvest)
library(stringr)
library(lubridate)
```
- `rvest`: read and process HTML data (select element, class, or text)
- `stringr`: string manipulation (ex. turn string to date)
- `lubridate`: manipulate date time format (ex. turn string to date time format)
## Find the number of last page
```R
url <- "https://ca.trustpilot.com/review/www.apple.com"
first_page <- read_html(url) 
```
`read_html()` will read from the URL, and return the source html code

## Generate a vector that store all pages
Because this website reviews other company’s website, each company’s website will have different number of pages depends on how popular the site. Because of that, we make a function that will return the last page number of a particular company it review (Apple.com in this case) so we can reuse in the future for other company.

```R
get_last_page <- function(html) { pages_data <- html %>%
    html_nodes(".pagination-link_item__mkuN3") %>%
    html_text()
  pages_data[length(pages_data)] %>%
    as.numeric()
}
(last_page <- get_last_page(first_page))
```
```
## [1] 293
```
There are 293 pages in total
- `html_nodes()`: find the section of the html source code that contain the input node
- `html_text()`: return the content of that section
- `as.numeric()`: convert it to numeric type
## Scrap data from each of the sub-webpage from the vector
```R
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

get_review_date <- function(html) {
    html %>%
    html_nodes('.typography_body-m__xgxZ_.typography_color-black__5LYEn') %>%
    html_text() %>%
    str_match("(?<=experience: ).*$") %>%
    mdy()
}
```

- Same as above, we use element selector gadget to select element that we want to scrap, copy that into `rvest::html_nodes()` then extract the text using `rvest::html_text()`. `stringr::str_trim()` to trim the white space at the start and end of the content. The result is a vector with all the comment.
- The date is a bit tricky, it’s a string contains unnecessary letter so we use RegEx and `stringr::str_match()` to extract the date part only, then convert to data format using `lubridate::mdy()`

Last part is the rating, because it’s a picture type so instead of reading the section content, we will read the attribute content instead

```R
get_review_rate <- function(html) { html %>%
    html_nodes('.styles_reviewHeader__iU9Px img') %>%
    html_attrs() %>%
    map(1) %>%
    str_trim() %>%
    str_extract("(?<=Rated ).(?= out)") %>%
    as.numeric()
```
- `rvest::html_attrs()` read the attributes in that node
- `purrr::map()` select the first attribute in this case, because it contain the number of stars reviewing.
- Then we use `stringr::str_extract()` and RegEx again to extract the useful content which is the
star number

## Combine the data into a single comprehensive data frame
Finally, we will write a function to combine all the function above and make data frame from a single URL then another function to combine all the data frame into a tibble
```R
get_data_table <- function(url, companyName) {
    html <- read_html(url)
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
```
After have all the vector such as reviewer name, comment, date, rate, we combine them as a tibble, `dplyr::mutate()` new column that contains company name, then `dplyr::select()` to arrange columns keep the consistent of all tibbles
Now we will write a function with loop control that will read all the page of that particular company
```R
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
```
- `dplyr::bind_rows()` combine first tibble input and second tibble input
- We loop until the end of the `list_of_pages`, then export the tibble data frame.
We will have the output as follow
```R
(data <- scrape_write_table(url, "APPLE"))
```
```
## # A tibble: 5,855 x 5
##    company reviewer          date
##    <chr>   <chr>             <date>
##  1 APPLE   Abimbola Bamikole 2023-01-04
##  2 APPLE   Janet Wright      2023-03-16
##  3 APPLE   Rob Leroy         2023-03-18
##  4 APPLE   Ice House Design  2023-03-15
##  5 APPLE   noreen darragh    2023-03-19     1 This Company is so annoying
##  6 APPLE   Paul Morgan
##  7 APPLE   wizard
##  8 APPLE   Nicole Sireci
##  9 APPLE   nets
## 10 APPLE   Charlotte
## # ... with 5,845 more rows
```
## Problem note
1. **Website update**:
One obvious problem is that the website owner decide to change the webpage like upgrade, update, changing structure     of the site which will require us to review the code
2. **Rate limited**:
I was trying to scrap a company with 57,599 reviewer in 2537 pages which mean require 2537 request to the server, after ran the code, my IP address was being block from further access to the website to prevent server overload or even DDoS attack. In such case, I would either set up a proxy server or limited the rate to wait a couple minutes or even hours between each request
3. **Inconsistent data**:
During scrapping, I noticed some inconsistencies of the website, such as some review will have no comment but only title and rate, which will lead to inconsistent length between vector which can leads to error or incorrect tibble. In such case, I would extract data by each comment which will be much longer
4. **UI Interaction**:
Some data will only show up after an interaction such as click a button for data to show up. In such case, there is API or click bot that can help you with this.
## Citation list
https://ca.trustpilot.com/review/www.canadianappliance.ca https://ca.trustpilot.com/review/www.apple.com
https://github.com/abhimotgi/dataslice/blob/master/R/Web%20Scraping%20with%20RVest%20Part%201.R
https://www.youtube.com/watch?v=v8Yh_4oE-Fs&t=209s https://www.datacamp.com/tutorial/r-web-scraping-rvest https://axiom.ai/blog/5-problems-webscrapers.html

# Extra information about lab work.
## Lab 1
Worked with library dplyr, gapminder
Summarized data 
Plot data using `ggplot` with `geom_point()` and `geom_smooth`
Filter data using 'filter'
## Lab 2
Analyzed data given by instructor with `library(tidyverse)`
1. Plot time series of HIV prevalence by year for each country, analyze the purpose of `alpha`
2. Filtered data and make sub data set, plots sub data overlap with old data but highlight for a more clear data representation
## Lab 3
1. Plot data from lab 2, and analyzed the differences between `geom_line()` and `geom_smooth()`.
2. Make new plot with group of countries with high hiv and the rest, added layers of `geom_smooth()` for 2 group (high hiv and the whole world)
## Lab 4
**Column Name Change**: Rename the first column of the data frame from "Estimated.HIV.Prevalence.....Ages.15.49" to "Country."
**Sparse Data Removal**: Eliminate columns with sparse data from 1979 to 1989 in the data frame.
**Descending Prevalence Sorting**: Sort the data by HIV prevalence in 2011 in descending order and display the top 6 rows.
**Data Manipulation Pipeline**: Chain operations 1 to 3 on a copy of the data frame called "hivcopy" using the pipe operator.
## Lab 5
**Data Import**: Import genomic variant data from the file "MLLT3_small.vcf" into R, excluding metadata lines.
**Column Specification Adjustment**: Use the 'spec()' function to generate a list of column specifications. Modify this list to ensure that the REF and ALT variables are read as factors.
**Column Renaming**: Rename the first column as 'CHROM,' taking into account the presence of the '#' symbol in the column name, which is often referred to as a 'nonsyntactic' name.
## Lab 6
**Sparse Data Removal**: Eliminate columns from the data frame that correspond to the years 1979 to 1989 due to sparse data.
**Data Reshaping and Sorting**: Reshape the yearly prevalence estimates into a longer tibble, creating three columns: "Country," "year," and "prevalence." While pivoting, exclude explicitly missing values. Finally, sort the resulting tibble by the "Country" column.
## Lab 7 
**Data Enhancement**: Incorporate the latitude and longitude data from the "airports" table into the "flights" table using a join function. This will provide geographical information for each airport destination.
**Flight Combinations Analysis**: Create a new table that identifies year-month-day-flight-tailnum combinations with more than one flight, accounting for cases with missing tail numbers. Apply this table as a filter to the "flights" dataset and select carrier, flight, origin, and destination details. Additionally, determine which airline utilized the same flight number for trips from La Guardia to St. Louis in the morning and from Newark to Denver in the afternoon.
**Top Departure Delay Analysis**: Recreate the "top_dep_delay" table, initially introduced in lecture 7 notes. This table comprises the three dates with the highest total departure delays. Total delay is calculated as the sum of the "dep_delay" variable for each year-month-day. For each of these top-delay days, calculate and report the median, third quartile, and maximum values of the "dep_delay" variable within the "flights" dataset.
## Lab 8
**Data Import**: Read youth unemployment data from the file "API_ILO_country_YU.csv" into a tibble named "youthUI."
**Data Reshaping**: Reshape the "youthUI" tibble using an appropriate pivot function to create a longer table with columns for "Country Name," "Country Code," "year," and "Unemployment Rate." Convert the "year" column to an integer vector. Arrange the rows by year and then by "Country Name" within each year.
**Data Visualization**: Plot unemployment rates by year for each country in "youthUI," representing each time series with a line. Adjust alpha levels to manage overplotting.
**Data Subsetting and Transformation**: Use regular expressions to extract a subset of countries from "youthUI" with names containing "(IDA & IBRD countries)" or "(IDA & IBRD)." Save this subset in a tibble called "youthDevel." Remove the "(IDA & IBRD countries)" or "(IDA & IBRD)" substring from the country names.
**Region-Wise Data Visualization**: Plot unemployment rates by year for each region in "youthDevel," using different colors for each region. Include both points and lines for each region. Add a layer to include worldwide unemployment data from "youthUI" where "Country Name" is "World."
# Lab 9
Converted the Date/Time variable to a date object and renamed it as "Date."
Created a time series plot of daily maximum temperatures by day.
Transformed the numeric Month variable into a factor, utilizing the "month()" function with the "label=TRUE" option to extract months from date-time data.
Plotted the average maximum temperature against the month. Additionally, you recreated this plot with months ordered by average maximum temperature.
# Lab 10
