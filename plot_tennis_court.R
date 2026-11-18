##################################################################
# plot_tennis_court.R
# R Project: PlotTennisCourt
#
# Usage:
#   source("plot_tennis_court.R")
#   plot_tennis_court(court_colour = "#5f819a", boundary_colour = "#508dba")
#
# Coordinates are metres with the origin at the centre of the net; the court
# runs along the y axis. Dimensions follow the ITF Rules of Tennis.
##################################################################

#Load necessary libraries
library(ggplot2)    #Package for creating graphics

#Court dimensions (metres)
court_length    <- 23.77   #Baseline to baseline (78 ft)
doubles_width   <- 10.97   #Between the doubles sidelines (36 ft)
singles_width   <- 8.23    #Between the singles sidelines (27 ft)
service_length  <- 12.80   #Service line to service line, 6.40m each side of the net (42 ft)
post_spacing    <- 12.80   #Net posts sit 0.914m (3 ft) outside each doubles sideline
runoff_width    <- 18.288  #Overall playing area including run-off (60 ft)
runoff_length   <- 36.576  #Overall playing area including run-off (120 ft)
line_width      <- 0.05    #All lines are 5cm wide
centre_mark_len <- 0.10    #The centre mark is 10cm long

#Every court line as a rectangle. Lines lie inside the dimensions they mark.
court_lines <- local({
  L  <- court_length / 2
  D  <- doubles_width / 2
  S  <- singles_width / 2
  SV <- service_length / 2
  w  <- line_width
  data.frame(
    line = c("doubles sideline", "doubles sideline", "baseline", "baseline",
             "singles sideline", "singles sideline", "centre service line",
             "service line", "service line", "centre mark", "centre mark"),
    xmin = c(-D,     D - w,  -D,     -D,     -S,     S - w,  -w / 2, -S,      -S,     -w / 2, -w / 2),
    xmax = c(-D + w, D,       D,      D,     -S + w, S,       w / 2,  S,       S,      w / 2,  w / 2),
    ymin = c(-L,    -L,      -L,      L - w, -L,    -L,      -SV,    -SV,     SV - w, -L,     L - centre_mark_len),
    ymax = c( L,     L,      -L + w,  L,      L,     L,       SV,    -SV + w, SV,     -L + centre_mark_len, L)
  )
})

#Define the function to plot the tennis court
plot_tennis_court <- function(court_colour = "#5f819a", boundary_colour = "#508dba"){

  #This function, plot_tennis_court, generates a graphical representation of a tennis court.

  #The function takes two parameters:
  #- court_colour: The colour of the inside of the tennis court (default is #5f819a).
  #- boundary_colour: The colour of the outside of the tennis court (default is #508dba).

  #It returns a ggplot object, so further layers can be added with `+`.

  posts <- data.frame(x = c(-post_spacing / 2, post_spacing / 2), y = c(0, 0))

  ggplot() +

    #Plot shape of the outer court boundary (coloured by the boundary_colour input)
    annotate("rect", xmin = -runoff_width/2, xmax = runoff_width/2,
             ymin = -runoff_length/2, ymax = runoff_length/2,
             fill = boundary_colour) +

    #Plot shape of the inner court boundary (coloured by the court_colour input)
    annotate("rect", xmin = -doubles_width/2, xmax = doubles_width/2,
             ymin = -court_length/2, ymax = court_length/2,
             fill = court_colour) +

    #Plot the lines on the tennis court (coloured in white)
    geom_rect(data = court_lines, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = "#ffffff") +

    #Plot the net and the net posts
    geom_segment(aes(x = -post_spacing/2, y = 0, xend = post_spacing/2, yend = 0), linewidth = 0.5, color = "black") +
    geom_point(data = posts, aes(x = x, y = y)) +

    #Remove background and set aspect ratio
    theme_void() +
    coord_fixed(ratio = 1)
}
