library(shiny)
library(tidyverse)
library(DT)
library(shinythemes)
library(scales)

#read the data file
employ <- read_csv("employees-all.csv")

#create a single variable for pay
employ <- employ %>%
  mutate(either = ifelse(is.na(hourly_rate), salary_rate, hourly_rate))

ui <- fluidPage(
  #set theme
  theme = shinytheme("cosmo"), 
  titlePanel("Pay of City of Chicago Employees "),
  sidebarLayout(
    sidebarPanel(
      #creating addition
      radioButtons(inputId = "salary",
                   label = "Salary or Hourly",
                   choices = c("Salary", "Hourly")), 
      #creating conditional panel
      uiOutput("conditionalPanel"),
      radioButtons(inputId = "full_time",
                   label = "Full or Part-Time",
                   choices = c("Full-Time", "Part-Time")),
      selectInput(inputId = "department",
                  label = "Department",
                  choices = sort(unique(employ$department)),
                  multiple = TRUE),
      uiOutput("jobTitle"),
      #adding download for full data file
      downloadButton("downloadData", "Download Full Data")
      
    ), 
    mainPanel(
      #tabs for each of the outputs
      tabsetPanel(tabPanel("List of Jobs", dataTableOutput("otherTable")),
                  tabPanel("Distribution of Pay",
                           plotOutput("payPlot"),
                           height = '100%'),
                  tabPanel("Number of Jobs", dataTableOutput("employTable"))))
))

server <- function(input, output) {
  employ_filter <- reactive({
    #sorts the tables
    employees <- employ %>%
      arrange(desc(either))
    
    # filter by salary or hourly
    if(!is.null(input$salary)) {
      employees <- filter(employees, salary %in% input$salary)
    }
    # filter by department
    if(!is.null(input$department)) {
      employees <- filter(employees, department %in% input$department)
    }
    
    # filter by job title
    if(!is.null(input$jobTitle)) {
      employees <- filter(employees, job_title %in% input$jobTitle)
    }
    
    # filter by full or part-time
    employees <- filter(employees, full_time == input$full_time)
    
    
    #filter by pay
    employees <- filter(employees,
                        either >= input$salary_rate[[1]],
                        either <= input$salary_rate[[2]])
  
  })
  
  #conditional rate panel
  output$conditionalPanel <- renderUI({
    employees <- employ
    if(input$salary == "Salary"){
      #creates max salary
      maxvar <- max(employ$salary_rate, na.rm = TRUE)
      labelvar <- "Salary rate"
    }
    else{
      #max hourly rate
      maxvar <- max(employ$hourly_rate, na.rm = TRUE)
      labelvar <- "Hourly rate"
    }
    
    sliderInput(inputId = "salary_rate",
                label = labelvar,
                min = 0,
                max = maxvar,
                value = c(0, maxvar)
  )
  
    
  }) 
  output$jobTitle <- renderUI({
    
    #sort table
    employees <- employ %>%
      arrange(desc(either))

    # filter by salary or hourly
    if(!is.null(input$salary)) {
      employees <- filter(employees, salary %in% input$salary)
    }
    
    # filter by department
    if(!is.null(input$department)) {
      employees <- filter(employees, department %in% input$department)
    }
    
    # filter by full or part-time
    employees <- filter(employees, full_time == input$full_time)
    
    # filter by hourly wage
    employees <- filter(employees,
                        either >= input$salary_rate[[1]],
                        either <= input$salary_rate[[2]])
   
    selectInput(inputId = "jobTitle",
                label = "Job Title",
                choices = sort(unique(employees$job_title)),
                multiple = TRUE)
  })
  
  
  output$payPlot <- renderPlot({
    #conditional plot to graph single values
    if(length(unique(employ_filter()$either)) == 1) {
      ggplot(employ_filter(), aes(either)) +
        geom_bar(aes(fill = department)) +
        labs(title = "Distribution of Pay",
             x = "Wage or Salary", 
             y = "Number of Employees", 
             caption = " Chicago Data Portal") +
        #gets rid of scientific notation
        scale_x_continuous(labels = scales::comma)
    
    }
    else {
     ggplot(employ_filter(), aes(either)) +
        geom_histogram(aes(fill = department)) +
        labs(x = "Wage or Salary", 
             y = "Number of Employees", 
             caption = "Chicago Data Portal") +
        theme(legend.position = 'bottom',
              legend.direction = 'vertical',
              legend.key.height = unit(0.1, "cm")) +
        #gets rid of scientific notation
        scale_x_continuous(labels = scales::comma)
     
    }
   
  }, height = 550, width = 550 #makes the graph larger
  )
  
  #interactive data table
  output$employTable <- renderDataTable({
    employ_filter() %>%
    count(job_title) %>%
    datatable(colnames = c("Job Title", "Number"),
              extensions = "Scroller", #allows you to scroll
              options = list(
                deferRender = TRUE,
                scrollY = 500,
                scroller = TRUE
                )
    ) 
      
  })
  
  output$otherTable <- renderDataTable({
    employ_filter() %>%
      select(job_title, either, department) %>%
      datatable(colnames = c( "Job Title","Pay", "Department"), 
                filter = 'bottom', #search directly for entries
                extensions =c("Buttons", "Scroller"), 
                options = list(
                  deferRender = TRUE,
                  scrollY = 500,
                  scroller = TRUE, # allows you to scroll
                  dom = 'Bfrtip',
                  buttons = c( 'csv', 'excel', 'pdf')) #download selected info
                ) %>%
      formatCurrency(c(2))  # gives wage and salary a $
      
  })
  
  #allowing the download button to work
  output$downloadData <- downloadHandler(
       filename = function() {
         paste('data-', Sys.Date(), '.csv', sep='')
       },
       content = function(con) {
         write.csv(employ, con) 
    })
  
  
  
}
shinyApp(ui = ui, server = server)
