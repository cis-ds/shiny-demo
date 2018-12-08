# Chicago app extention

My app is [here](https://liamcoles.shinyapps.io/liams_first_app/), and the code to create it can be found in [this](app.R) file.

The data used for this application can be downloaded [here](employees-all.csv). Though, the orignal data is from the [Chicago Data Portal](https://data.cityofchicago.org/) website. 

This app is a continuation of the basis Chicago Wage App in the Uchicago Computing for the Social Sciences class. This version extends this by adding salaried workers and a couple other features. It still has all of the original features. For a look at the original app click [here](https://cfss.uchicago.edu/shiny.html#final_shiny_app_code).


## Tabs
Using the `tabsetPanel` function, I created three tabs. 

### 1

The first is the `List of Jobs` tab, which is a table that lists the job titles, pay, and department of any selected group. The default is the descending order of Full-Timed salaries.

### 2

The second is the `Distribution of Pay`, which is the graph from the orignal app. I color coded the departments to give a sense of what jobs pay what money. The graph charts both wages and salaries given your selection. The wages are *per hour* and, therefore, much lower when graphed than the yearly salaries. 

This graph, unlike the previous one, can graph a single wage or salary. I use a conditional statement that takes single wage or salary and maps it to a `geom_bar` in `ggplot2`, which can take single discrete widths, where the normal `geom_histogram` cannot.

### 3

The third tab is `Number of Jobs`. This is just the original count of the number of jobs in each department. 


## Packages and features

Using the `DT` package I added two interactive tables. Using the `Button` extention, you are able to download your selected information into a `csv`, `pdf`, or `excel` document. (Also, if you want to download the full data from the application, there is a download button using the `downloadButton` function). Furthermore, using the `Scroller` extension, you are able to scroll through the data, instead of clicking through pages. 

For greater specifity, you are also able to search for entries at the bottom of the the `List of Jobs` table using the `filter` setting in `DT`. 

For the graph, I used the `scales` function to get rid of the scientific notation. 

The theme from the `shinythemes` package is `cosmo`. 

Other packages needed are `shiny` and `tidyverse`.
