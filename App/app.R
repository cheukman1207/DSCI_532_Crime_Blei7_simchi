#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(DT)
library(plotly)


#load data
crime_df  <- read_csv("../data/cleaned_crime.csv") %>% 
    mutate(city = as.factor(city))

ui <- fluidPage(
        titlePanel("Visualizing Crimes in US"),
        
        
        sidebarLayout(
          sidebarPanel(
            style = "position:fixed;width:inherit;",
            # Input: select city
            selectInput("city",
                        label = "Cities: (where do you want to live?)",
                        choices = crime_df$city,
                        multiple = TRUE,
                        selected = c('Cleveland','Boston')),
            #Input: select crime type
            radioButtons("crime", 
                         label = "Crimes",
                         choices = c("Homicide", "Rape", "Robbery", "Assault", "All Crimes"),
                         selected = "All Crimes"),
            #Input: select years
            sliderInput("year", 
                        label ="Year",
                        min = 1975, max = 2015,
                        value = c(1975,2015),
                        step = 1, sep = "")

          ),
          
          
          
          mainPanel(
            tabsetPanel(type = "tabs",
              tabPanel("Plot", plotlyOutput("TimeSeries"),
                                        plotlyOutput("boxplot")),
              tabPanel("Data", span("Data source:",
                                    tags$a(href = "https://github.com/themarshallproject/city-crime", "The Marshall Project")), dataTableOutput("table")),
              tabPanel("About", 
                       h2("Description"),
                       br(), 
                       "This web app allows for visual comparision of crimes between cities as well as the trend in crime rate. 
                       The user can filter by cities, crime type and the period from 1975-2015. The dataset is compiled by the", tags$a(href = "https://github.com/themarshallproject/city-crime", "The Marshall Project"), "in which the data is collected from 68 police jurisdictions across the United States between 1975 to 2015. The dataset consists of 2829 records, covering four types of violent crimes ,such as rape, homicides, robbery, and aggravated assault.",
                       br(), 
                       br(),
                       br(),
                       "Contributors: Bailey Lei, Simon Chiu",
                       br(),
                       span("Github Repository:",
                            tags$a(href = "https://github.com/UBC-MDS/DSCI_532_Crime_Blei7_simchi", "Visualizing crimes in US")),
                       br(),
                       "Please contact Bailey Lei (baileylei@gmail.com) with questions, comments or concerns.")
                      

            )
          )
        )
)

server <- function(input, output) {
  
  #filter data frame based on user input
  filtered <- reactive({
    crime_df %>%
      filter(year >= input$year[1],
             year <= input$year[2],
             city %in% input$city,
             category == input$crime
      )
     
  } )
  
  #Time series plot of crime rates 
  output$TimeSeries <- renderPlotly({
    filtered() %>% 
        ggplot(aes(year, crime_rate)) +
        geom_line(aes(colour=city, group=category))+
        xlab("") +
        ylab("cases per 100,000 people") + 
        ggtitle(paste("Time Series of", input$crime, "Cases in U.S. from", input$year[1], "to", input$year[2]))
  })
  
  #Boxplot of crime rates  
  output$boxplot <- renderPlotly({hide_legend(
    filtered() %>% 
      ggplot(aes(city, crime_rate)) +
      geom_boxplot(aes(fill = city, alpha=0.7)) + 
      xlab("") +
      ylab("cases per 100,000 people") +  
      theme(axis.text.x = element_text(angle=45, hjust=1))+
      ggtitle(paste("Distribution of", input$crime, "cases from", input$year[1], "to", input$year[2])))
    
    
  })
  
  #Dataset 
  output$table<-DT::renderDataTable(
    {
      DT::datatable(filtered(),options = list(lengthMenu = c(30,50,100),pageLength = 10))
    }
  )
  
}
shinyApp(ui = ui, server = server)