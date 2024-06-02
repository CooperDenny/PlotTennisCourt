##################################################################
# plot_tennis_court.R
# R Project: PlotTennisCourt
##################################################################

#Load necessary libraries
library(tidyverse)  #Collection of R packages for data manipulation and visualization
library(ggplot2)    #Package for creating graphics
library(ggforce)    #Package for additional ggplot2 functionalities

#Define the function to plot the tennis court
plot_tennis_court <- function(court_colour = "#5f819a", boundary_colour = "#508dba"){
  
  #This function, plot_tennis_court, generates a graphical representation of a tennis court.
  
  #The function takes two parameters:
  #- court_colour: The colour of the inside of the tennis court (default is #5f819a).
  #- boundary_colour: The colour of the outside of the tennis court (default is #508dba).
  
  ggplot()+
    
    #Plot shape of the outer court boundary (coloured by the boundary_colour input)
    annotate("rect", xmin = -18.288/2, xmax = 18.288/2,
             ymin = -36.576/2, ymax = 36.576/2,
             alpha = 1, fill = boundary_colour) +
    
    #Plot shape of the inner court boundary (coloured by the court_colour input)
    annotate("rect", xmin = -10.973/2, xmax = 10.973/2,
             ymin = -23.774/2, ymax = 23.774/2,
             alpha = 1, fill = court_colour) +
    
    #Plot the lines on the tennis court (coloured in white)
    annotate("rect", xmin = -10.973/2, xmax = -10.973/2+0.05,
             ymin = -23.774/2, ymax = 23.774/2,
             alpha = 1, fill = "#ffffff") +
    annotate("rect", xmin = 10.973/2-0.05, xmax = 10.973/2,
             ymin = -23.774/2, ymax = 23.774/2,
             alpha = 1, fill = "#ffffff") +
    annotate("rect", xmin = -10.973/2, xmax = 10.973/2,
             ymin = -23.774/2, ymax = -23.774/2+0.05,
             alpha = 1, fill = "#ffffff") +
    annotate("rect", xmin = -10.973/2, xmax = 10.973/2,
             ymin = 23.774/2-0.05, ymax = 23.774/2,
             alpha = 1, fill = "#ffffff") +
    annotate("rect", xmin = -8.23/2, xmax = -8.23/2+0.05,
             ymin = -23.774/2, ymax = 23.774/2,
             alpha = 1, fill = "#ffffff") +
    annotate("rect", xmin = 8.23/2, xmax = 8.23/2-0.05,
             ymin = -23.774/2, ymax = 23.774/2,
             alpha = 1, fill = "#ffffff") +
    annotate("rect", xmin = -0.025, xmax = 0.025,
             ymin = -12.802/2, ymax = 12.802/2,
             alpha = 1, fill = "#ffffff") +
    annotate("rect", xmin = -8.23/2, xmax = 8.23/2,
             ymin = -12.802/2, ymax = -12.802/2+0.05,
             alpha = 1, fill = "#ffffff") +
    annotate("rect", xmin = -8.23/2, xmax = 8.23/2,
             ymin = 12.802/2, ymax = 12.802/2-0.05,
             alpha = 1, fill = "#ffffff") +
    annotate("rect", xmin = -0.025, xmax = 0.025,
             ymin = -23.774/2, ymax = -23.774/2+0.25,
             alpha = 1, fill = "#ffffff") +
    annotate("rect", xmin = -0.025, xmax = 0.025,
             ymin = 23.774/2-0.25, ymax = 23.774/2,
             alpha = 1, fill = "#ffffff") +
    
    #Plot the net
    geom_segment(aes(y = 0, x = -12.802/2, yend = 0, xend = 12.802/2), linewidth = 0.5, color = "black") +
    geom_point(aes(x = c(-12.802/2,12.802/2), y = c(0,0))) +
    
    #Remove background and set aspect ratio
    theme_void() +
    coord_fixed(ratio = 1)
}



