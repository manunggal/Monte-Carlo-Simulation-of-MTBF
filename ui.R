# library
library(plotly)
library(shiny)
library(shinydashboard) 

# UI
# header = (dashboardHeader(title = "Monte Carlo Simulation of MTBF",
#                           titleWidth = 300))
header = dashboardHeader(title = span("Monte Carlo Simulation of MTBF",
                                      style = "font-size: 18px"),
                         titleWidth = 300)

sidebar = dashboardSidebar(
  width = 300,
  menuItem("Simulation Input", tabName = "sim_input", icon = icon("stopwatch")),
  numericInput("mtbf", "MTBF (Years):", 5),
  numericInput("mttr", "MTTR (Hours):", 5),
  numericInput("mission_time", "Mission Time Duration (Years)", 5, min = 1, max = 20),
  br(), # linebreak
  menuItem("Simulation Setting", tabName = "setting", icon = icon("cogs")),
  numericInput("sim_number", "Simulations Number:", 100, min = 10, max = 100000),
  br(), # linebreak
  actionButton("simulate", "Start Simulation", icon("paper-plane"), 
               style="color: #fff; background-color: #A52A2A; border-color: #A52A2A"),
  br(), # linebreak
  menuItem("Source code for The App", icon = icon("file-code-o"), 
           href = "https://github.com/manunggal/Monte-Carlo-Simulation-of-MTBF")
)

body = dashboardBody(
  fluidRow(
    column(width = 6,
           box(
             title = "About the simulation", width = NULL, solidHeader = TRUE, status = "primary",
             p("The purpose of this Monte Carlo simulation is to illustrate the relation between MTBF, mission duration, and their impact to the possible numbers of failures.
               For simplicity, constant failure rate is assumed for the input, hence failure rate equals to 1/MTBF. After each reparation, component is assumed to be as good as new."),
             p("You can play around with MTBF, MTTR, and mission time duration in order to see how they drives the reliability and numbers of probable failures.
               The simulation number will impact on how good the simulation approximate the expected value. More simulation numbers will converge the result to expected value.
               Simulation numbers is limited to 100.000 iteration."),
             p("The deterministic reliability is the estimated reliability from equation R = exp(-lambda x mission_time), whereas the simulated reliability is the result of the Monte Carlo simulation."))),
    column(width = 3,
           valueBoxOutput("failure_rate", width = NULL),
           valueBoxOutput("availability", width = NULL)),
    column(width = 3,
           valueBoxOutput("reliability_det", width = NULL),
           valueBoxOutput("reliability_sim", width = NULL))
  ),
  fluidRow(box(plotlyOutput("plot_reliability"), width = 4,
               title = "Reliability Timeseries",
               status = "primary", solidHeader = TRUE),
           box(plotlyOutput("plot_pie_reliability"), width = 4,
               title = "Reliability at Mission Time",
               status = "primary", solidHeader = TRUE),
           box(plotlyOutput("plot_maintenance"), width = 4,
               title = "Failure Numbers Probability",
               status = "primary", solidHeader = TRUE))
)

ui = dashboardPage(header, sidebar, body) 