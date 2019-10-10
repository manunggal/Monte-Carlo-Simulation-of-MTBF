# Load Relevant Library
#------------
library(dplyr)
library(purrr)
library(ggplot2)
library(plotly)
library(magrittr)
library(fBasics)
library(gridExtra)
library(reshape2)
library(hash)  
library(htmlwidgets)
library(shiny)
library(shinydashboard) 
library(DT)

# server
server = function(input, output) {
  
  set.seed(8)
  # initial condition
  mission_time_vec = eventReactive(input$simulate, {
    c(1:round(input$mission_time, digits = 0))
  })
  
  maintenance_duration = eventReactive(input$simulate, {
    input$mttr
  })
  
  r_sys_det = eventReactive(input$simulate, {
    round(exp(-1*(1/input$mtbf)*mission_time_vec())*100, digits = 2)
  })
  
  ttf_turbine = eventReactive(input$simulate, {
    (-1/(1/input$mtbf))*log(1-(cbind(runif(input$sim_number))))
  })
  
  # ttf_turbine = (-1/(1/input$mtbf))*log(1-(cbind(runif(input$sim_number))))
  
  r_sys_sim = reactive({
    r_sys_sim_data = 0
    for (i in 1:tail(mission_time_vec(), n=1)){
      r_sys_sim_data[i] = round(
        mean((ttf_turbine() >= i)*1)*100,
        digits = 2)
    }
    r_sys_sim_data
  })
  
  # RAM Simulation
  # failure and reparation 
  avsys = function(x)
  {
    res = data.frame(rep = double(), fc_afrep = double(), cumt = double())
    sumr = data.frame(reptime = double(), failnum = double(), tottime = double())
    if(x >= tail(mission_time_vec(), n=1)) {res[1L,] = c(0, 0, 0); sumr[1L,] = c(0, 0, 0)} # #sum.id=c(0) summary of reparation
    else
    {i = 1L
    repeat
      
    {
      # time to failure after rerun after reparation
      fc_afrep = (-1/(1/tail(mission_time_vec(), n=1)))*log(1-(c(runif(length(input$mission_time)))))
      
      # reparation duration
      rep = input$mttr/(24*365)
      
      
      
      # result
      cumt = (rep+fc_afrep) # cumulative time after reparation and follow up random simulation
      res[i,] = c(rep, fc_afrep, cumt) # summary of reparation, id of other failure, ttf of other failure, cumulative time)
      tottime = sum(res$cumt) # cummulative operation time to be compared with mission time
      reptime = sum(res$rep) # total reparation time
      failnum = length(res$rep) # total reparation numbers
      
      
      sumr[1L,] = c(reptime, failnum, tottime) # summary of reparation time, failure number, and total operating time
      # repsum[i,] = c(fc_afrep_id, fcid_afrepline1, fcid_afrepline2, fcid_afrepline3, fcid_afrepline4) # summary of components contributing to system failure
      print(res)
      if (tottime+x >= tail(mission_time_vec(), n=1)) break
      i=i+1L
    }
    }
    return(list(res,sumr))
  }
  
  # collect simulation result
  av_sys = eventReactive(input$simulate, {
    av_sys = map(ttf_turbine(), avsys)
  })
  
  sum_av_sys = eventReactive(input$simulate, {
    data = t(sapply(av_sys(), "[[", 2))
    
  })
  
  aval_sys = eventReactive(input$simulate, {
    melt(lapply(sum_av_sys()[1:input$sim_number, 1], function(x) ((tail(mission_time_vec(), n=1)-x)/tail(mission_time_vec(), n=1)))) #calculate availability for each iteration
  })
  
  # calculate percentage of system sucess without failure
  rep_no_sys = eventReactive(input$simulate, {
    melt(sum_av_sys()[1:input$sim_number,2]) #number of failure for each iterations
  }) 
  
  sum_rep_no_sys = eventReactive(input$simulate, {
    (table(rep_no_sys()[,1])) # distribution of failure numbers and without failures
  }) 
  
  
  # comparison of number of failure (distribution of failure number for n simulation)
  mean_rep_no_sys = eventReactive(input$simulate, {
    mean(rep_no_sys()[,1])  # mean  number of failure during n iteration
  }) 
  
  sd_rep_no_sys = eventReactive(input$simulate, {
    sd(rep_no_sys()[,1]) # standard deviation
  }) 
  
  
  # Display Main Variables
  output$failure_rate = renderValueBox({
    valueBox(
      1/input$mtbf, "Failure Rate per Year", 
      color = "red", icon = icon("wrench"))
  })
  
  output$reliability_det = renderValueBox({
    valueBox(
      paste(tail(r_sys_det(), n = 1), "%"), 
      paste("Deterministic Reliability at", input$mission_time, "year(s)"), color = "green", icon = icon("chart-line"))
  })
  
  output$reliability_sim = renderValueBox({
    valueBox(
      paste(tail(r_sys_sim(), n = 1), "%"), 
      paste("Simulated Reliability at", input$mission_time, "year(s)"), color = "green", icon = icon("chart-line"))
  })
  
  output$availability = renderValueBox({
    valueBox(
      paste(round((mean(aval_sys()[,1]))*100, digits = 2), "%"), 
      paste("Availability at", input$mission_time, "year(s)"), color = "blue", icon = icon("chart-bar"))
  })
  
  
  # render plot
  output$plot_reliability = renderPlotly({
    plot_ly() %>% 
      add_trace(x = mission_time_vec(), y = r_sys_det(), 
                type = 'scatter', mode = "lines", name = "Deterministic Reliability") %>%
      add_trace(x = mission_time_vec(), y = r_sys_sim(), 
                type = 'scatter', mode = "lines", name = "Simulated Reliability") %>%
      layout(yaxis = list(title = "Reliability (%)"), xaxis = list(title = "Year"), hovermode = 'compare')
  })
  
  output$plot_pie_reliability = renderPlotly({
    wwf = data.frame(labels = c("Without Failure", "With Failure and Reparation"),
                     values = c(sum_rep_no_sys()[1], sum(sum_rep_no_sys()[2:length(sum_rep_no_sys())])))
    plot_ly(wwf, labels = ~labels, values = ~values, type="pie")
  })
  
  output$plot_maintenance = renderPlotly({
    plot_ly(x = as.factor(names(sum_rep_no_sys())),
            y = (round(100*sum_rep_no_sys()/sum(sum_rep_no_sys()), 1)),
            name = paste("Failure Numbers Probability for", input$mission_time, "year(s)") , type = "bar") %>%
      layout(xaxis = list(title = "Number of Failures", dtick = 1),
             yaxis = list(title = "Probability of Occurence (%)", dtick= 5),
             title = paste(as.character(mean_rep_no_sys()), 
                           "Expected Failure Numbers", "<br>", "for", tail(mission_time_vec(), n=1), "year(s)"),
             font = list(size = 10))
  })
  
}