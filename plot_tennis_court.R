##################################################################
# plot_tennis_court.R
# R Project: PlotTennisCourt
#
# Usage:
#   source("plot_tennis_court.R")
#   plot_tennis_court(court_colour = "#5f819a", boundary_colour = "#508dba")
#   plot_tennis_court(surface = "clay", half = TRUE, singles_sticks = TRUE)
#   tennis_serve_map(serves)
#   tennis_court_side()
#
# Coordinates are metres with the origin at the centre of the net; the court
# runs along the y axis (along x with orientation = "horizontal"). Dimensions
# follow the ITF Rules of Tennis. Every function returns a ggplot object.
##################################################################

#Load necessary libraries
library(ggplot2)    #Package for creating graphics

#Court dimensions (metres)
court_length    <- 23.77   #Baseline to baseline (78 ft)
doubles_width   <- 10.97   #Between the doubles sidelines (36 ft)
singles_width   <- 8.23    #Between the singles sidelines (27 ft)
service_length  <- 12.80   #Service line to service line, 6.40m each side of the net (42 ft)
post_spacing    <- 12.80   #Net posts sit 0.914m (3 ft) outside each doubles sideline
stick_spacing   <- 10.06   #Singles sticks sit 0.914m (3 ft) outside each singles sideline
runoff_width    <- 18.288  #Overall playing area including run-off (60 ft)
runoff_length   <- 36.576  #Overall playing area including run-off (120 ft)
line_width      <- 0.05    #All lines are 5cm wide
centre_mark_len <- 0.10    #The centre mark is 10cm long
net_height_centre <- 0.914 #Net height at the centre strap (3 ft)
net_height_post   <- 1.07  #Net height at the posts (3.5 ft)

#Colour presets: court inside the doubles lines, then the run-off
court_surfaces <- list(
  hard  = c(court = "#5f819a", boundary = "#508dba"),
  clay  = c(court = "#b03c0b", boundary = "#b03c0b"),
  grass = c(court = "#84a25e", boundary = "#84a25e")
)

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

#Swap x and y in a data frame of rectangles, segments or points, to turn the court sideways
swap_xy <- function(d) {
  n <- names(d)
  n <- ifelse(n == "x", "y", ifelse(n == "y", "x",
       ifelse(n == "xmin", "ymin", ifelse(n == "ymin", "xmin",
       ifelse(n == "xmax", "ymax", ifelse(n == "ymax", "xmax",
       ifelse(n == "xend", "yend", ifelse(n == "yend", "xend", n))))))))
  names(d) <- n
  d
}

#Resolve the court and run-off colours from explicit colours or a surface preset
court_colours <- function(court_colour, boundary_colour, surface) {
  surface <- match.arg(surface, names(court_surfaces))
  preset  <- court_surfaces[[surface]]
  c(court    = if (is.null(court_colour)) preset[["court"]] else court_colour,
    boundary = if (is.null(boundary_colour)) preset[["boundary"]] else boundary_colour)
}

#Define the function to plot the tennis court
plot_tennis_court <- function(court_colour = NULL, boundary_colour = NULL,
                              surface = c("hard", "clay", "grass"), half = FALSE,
                              orientation = c("vertical", "horizontal"), singles_sticks = FALSE){

  #This function, plot_tennis_court, generates a graphical representation of a tennis court.

  #The function takes these parameters:
  #- court_colour: The colour of the inside of the tennis court (default is #5f819a, from `surface`).
  #- boundary_colour: The colour of the outside of the tennis court (default is #508dba, from `surface`).
  #- surface: "hard", "clay" or "grass" colour preset, used for any colour you don't give.
  #- half: TRUE shows only the far half (y > 0), where a player at the near baseline serves.
  #- orientation: "vertical" runs the court along y; "horizontal" runs it along x, so
  #  your data's x and y must be swapped to match.
  #- singles_sticks: TRUE marks the singles sticks used for singles on a doubles court.

  #It returns a ggplot object, so further layers can be added with `+`.

  cols        <- court_colours(court_colour, boundary_colour, surface)
  orientation <- match.arg(orientation)
  stopifnot(is.logical(half), length(half) == 1, is.logical(singles_sticks))

  areas <- data.frame(
    xmin = c(-runoff_width / 2, -doubles_width / 2), xmax = c(runoff_width / 2, doubles_width / 2),
    ymin = c(-runoff_length / 2, -court_length / 2), ymax = c(runoff_length / 2, court_length / 2),
    fill = cols[c("boundary", "court")]
  )
  lines <- court_lines
  net   <- data.frame(x = -post_spacing / 2, xend = post_spacing / 2, y = 0, yend = 0)
  posts <- data.frame(x = c(-post_spacing / 2, post_spacing / 2), y = c(0, 0))
  sticks <- data.frame(x = c(-stick_spacing / 2, stick_spacing / 2), y = c(0, 0))

  #Show the far half, plus a strip on the near side so the net is visible
  lim_len <- if (half) c(-0.8, runoff_length / 2) else c(-runoff_length / 2, runoff_length / 2)
  lim_wid <- c(-runoff_width / 2, runoff_width / 2)

  if (orientation == "horizontal") {
    areas <- swap_xy(areas); lines <- swap_xy(lines); net <- swap_xy(net)
    posts <- swap_xy(posts); sticks <- swap_xy(sticks)
    xlim <- lim_len; ylim <- lim_wid
  } else {
    xlim <- lim_wid; ylim <- lim_len
  }

  p <- ggplot() +

    #Plot the run-off area and the court (coloured by boundary_colour and court_colour)
    geom_rect(data = areas, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = areas$fill, inherit.aes = FALSE) +

    #Plot the lines on the tennis court (coloured in white)
    geom_rect(data = lines, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = "#ffffff", inherit.aes = FALSE) +

    #Plot the net and the net posts
    geom_segment(data = net, aes(x = x, y = y, xend = xend, yend = yend), linewidth = 0.5,
                 color = "black", inherit.aes = FALSE) +
    geom_point(data = posts, aes(x = x, y = y), inherit.aes = FALSE)

  if (singles_sticks) {
    p <- p + geom_point(data = sticks, aes(x = x, y = y), shape = 21, fill = "white",
                        colour = "black", size = 1.6, inherit.aes = FALSE)
  }

  #The full court keeps ggplot's usual margin; the half court is cropped to the run-off
  p +
    #Remove background and set aspect ratio
    theme_void() +
    if (half) coord_fixed(ratio = 1, xlim = xlim, ylim = ylim, expand = FALSE) else coord_fixed(ratio = 1)
}


#Serve zones in the far service boxes: each box split into wide / body / T thirds
#across its width. The deuce box is on the receiver's right, which is -x when the
#server is at the near (y < 0) baseline.
tennis_serve_zones <- function() {
  S  <- singles_width / 2
  SV <- service_length / 2
  third <- S / 3
  data.frame(
    box  = rep(c("Deuce", "Ad"), each = 3),
    zone = c("Wide", "Body", "T", "T", "Body", "Wide"),
    xmin = c(-S, -S + third, -S + 2 * third, 0, third, 2 * third),
    xmax = c(-S + third, -S + 2 * third, 0, third, 2 * third, S),
    ymin = 0, ymax = SV
  )
}

#Which serve zone each bounce landed in, or "Fault" if it missed both boxes
tennis_serve_zone_of <- function(x, y) {
  z <- tennis_serve_zones()
  out <- rep("Fault", length(x))
  for (i in seq_len(nrow(z))) {
    inside <- x >= z$xmin[i] & x <= z$xmax[i] & y >= z$ymin[i] & y <= z$ymax[i]
    out[inside & out == "Fault"] <- paste(z$box[i], z$zone[i])
  }
  out
}

#Where serves bounced, on the far half of the court, with each serve zone shaded by
#its share of the serves that went in.
tennis_serve_map <- function(data, x = "x", y = "y", colour = NULL,
                             court_colour = NULL, boundary_colour = NULL,
                             surface = c("hard", "clay", "grass"), labels = TRUE) {

  #- data: one row per serve, with the bounce position in court coordinates (server at
  #  the near baseline, so serves land at y > 0)
  #- colour: optional column to fill the points by (e.g. serve speed band or outcome)

  needed <- c(x, y, colour)
  if (!all(needed %in% names(data))) {
    stop("data must contain the columns ", paste(needed, collapse = ", "), ".", call. = FALSE)
  }
  bx <- data[[x]]
  by <- data[[y]]
  zone <- tennis_serve_zone_of(bx, by)

  zones <- tennis_serve_zones()
  zones$key <- paste(zones$box, zones$zone)
  zones$n <- as.integer(table(factor(zone, levels = zones$key)))
  served_in <- sum(zones$n)
  zones$share <- if (served_in > 0) zones$n / served_in else 0
  zones$label <- sprintf("%s\n%.0f%%\n(%d)", zones$zone, 100 * zones$share, zones$n)

  pts <- data.frame(x = bx, y = by, fault = zone == "Fault")
  if (!is.null(colour)) pts$group <- data[[colour]]

  p <- plot_tennis_court(court_colour, boundary_colour, surface = surface, half = TRUE) +
    geom_rect(data = zones, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, alpha = share),
              fill = "white", inherit.aes = FALSE) +
    scale_alpha_continuous(range = c(0.05, 0.55), limits = c(0, max(0.01, zones$share)),
                           guide = "none")

  if (labels) {
    p <- p + geom_text(data = zones, aes(x = (xmin + xmax) / 2, y = 1.3, label = label),
                       size = 2.3, lineheight = 0.9, colour = "grey10", inherit.aes = FALSE)
  }

  if (is.null(colour)) {
    p <- p + geom_point(data = pts[!pts$fault, ], aes(x, y), shape = 21, fill = "#DFFF4F",
                        colour = "black", size = 2, stroke = 0.4, inherit.aes = FALSE)
  } else {
    p <- p + geom_point(data = pts[!pts$fault, ], aes(x, y, fill = group), shape = 21,
                        colour = "black", size = 2, stroke = 0.4, inherit.aes = FALSE) +
      labs(fill = NULL) + theme(legend.position = "bottom")
  }
  #Faults as crosses
  p + geom_point(data = pts[pts$fault, ], aes(x, y), shape = 4, colour = "white", size = 1.8,
                 stroke = 0.8, inherit.aes = FALSE) +
    labs(caption = sprintf("%d serves, %d in (%.0f%%)", nrow(pts), served_in,
                           100 * served_in / max(1, nrow(pts)))) +
    theme(plot.caption = element_text(hjust = 0.5, colour = "grey30"))
}


#The court side-on, for ball trajectories and net clearance. x is metres along the
#court from the net (the same as y on plot_tennis_court()), y is height in metres.
#Add trajectories with geom_path(aes(x = along, y = height)). At true scale the view
#is a 9:1 strip, so heights are stretched by `height_scale` (stated on the plot).
tennis_court_side <- function(max_height = 4, height_scale = 2, court_colour = NULL,
                              boundary_colour = NULL, surface = c("hard", "clay", "grass")) {

  cols <- court_colours(court_colour, boundary_colour, surface)
  L  <- court_length / 2
  SV <- service_length / 2
  R  <- runoff_length / 2
  stopifnot(is.numeric(max_height), max_height > net_height_post,
            is.numeric(height_scale), height_scale > 0)

  ground <- data.frame(xmin = c(-R, -L), xmax = c(R, L), ymin = -0.25, ymax = 0,
                       fill = cols[c("boundary", "court")])
  marks  <- data.frame(x = c(-L, -SV, SV, L))
  marks$label <- c("Baseline", "Service line", "Service line", "Baseline")
  guides <- data.frame(y = seq(1, floor(max_height)))

  ggplot() +
    annotate("rect", xmin = -R, xmax = R, ymin = 0, ymax = max_height, fill = "#F4F7FB") +
    geom_hline(data = guides, aes(yintercept = y), colour = "grey85", linewidth = 0.3) +
    geom_text(data = guides, aes(x = -R + 0.3, y = y, label = paste0(y, "m")), hjust = 0,
              vjust = -0.4, size = 2.6, colour = "grey50", inherit.aes = FALSE) +
    geom_rect(data = ground, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = ground$fill, inherit.aes = FALSE) +

    #Line positions on the ground, labelled below
    geom_segment(data = marks, aes(x = x, xend = x, y = -0.25, yend = 0), colour = "white",
                 linewidth = 1, inherit.aes = FALSE) +
    geom_text(data = marks, aes(x = x, y = -0.25, label = label), vjust = 1.4, size = 2.5,
              colour = "grey30", inherit.aes = FALSE) +

    #The net: solid to its centre height, dashed to the height at the posts
    annotate("segment", x = 0, xend = 0, y = 0, yend = net_height_centre, linewidth = 1.6,
             colour = "grey15") +
    annotate("segment", x = 0, xend = 0, y = net_height_centre, yend = net_height_post,
             linewidth = 0.6, colour = "grey15", linetype = "dashed") +
    annotate("text", x = 0.35, y = c(net_height_centre - 0.05, net_height_post + 0.07),
             label = c("0.914 m (centre)", "1.07 m (posts)"), hjust = 0, size = 2.4,
             colour = "grey25") +

    labs(caption = if (height_scale != 1) paste0("Heights stretched ", height_scale, "x") else NULL) +
    theme_void() +
    theme(plot.caption = element_text(hjust = 1, colour = "grey45", size = 8)) +
    coord_fixed(ratio = height_scale, xlim = c(-R, R), ylim = c(-0.9, max_height), expand = FALSE)
}
