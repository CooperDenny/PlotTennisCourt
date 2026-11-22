##################################################################
# examples.R
# Regenerates every image in images/. Serve locations and ball flights are
# simulated, so the plots show what each function draws, not real match data.
#   Rscript examples.R
##################################################################

source("plot_tennis_court.R")

save <- function(plot, file, width, height) {
  ggsave(file.path("images", file), plot, width = width, height = height, dpi = 150, bg = "white")
}

set.seed(2026)

##################################################################
# Courts
##################################################################

save(plot_tennis_court(court_colour = "#5f819a", boundary_colour = "#508dba"), "tennis_court_1.png", 3.6, 6.6)
save(plot_tennis_court(court_colour = "#b03c0b", boundary_colour = "#b03c0b"), "tennis_court_2.png", 3.6, 6.6)
save(plot_tennis_court(court_colour = "#84a25e", boundary_colour = "#84a25e"), "tennis_court_3.png", 3.6, 6.6)
save(plot_tennis_court(court_colour = "#175fa3", boundary_colour = "#5c7e66"), "tennis_court_4.png", 3.6, 6.6)
save(plot_tennis_court(surface = "grass", half = TRUE, singles_sticks = TRUE), "tennis_half_court.png", 4.6, 5)
save(plot_tennis_court(surface = "clay", orientation = "horizontal"), "tennis_court_horizontal.png", 7, 3.8)

##################################################################
# Serve map: 90 simulated serves from the near baseline
##################################################################

zones <- tennis_serve_zones()
n <- 90
target <- zones[sample(nrow(zones), n, replace = TRUE, prob = c(3, 1, 3, 3, 1, 2)), ]
serves <- data.frame(
  x = (target$xmin + target$xmax) / 2 + rnorm(n, 0, 0.65),
  y = rnorm(n, 5.6, 1.0),
  serve = factor(sample(c("First serve", "Second serve"), n, replace = TRUE, prob = c(0.65, 0.35)))
)
save(tennis_serve_map(serves, colour = "serve") +
       scale_fill_manual(values = c(`First serve` = "#DFFF4F", `Second serve` = "#FF9F1C")),
     "tennis_serve_map.png", 5, 5.8)

##################################################################
# Side view: three illustrative ball flights from the near baseline
##################################################################

#Drag-free flight with one bounce. Stops at the net if the ball is below the tape.
flight <- function(label, v, angle, x0 = -11.9, h0 = 1, restitution = 0.7, keep = 0.75) {
  g  <- 9.81
  vx <- v * cos(angle * pi / 180)
  vy <- v * sin(angle * pi / 180)
  t_land <- (vy + sqrt(vy^2 + 2 * g * h0)) / g
  t  <- seq(0, t_land, length.out = 200)
  arc <- data.frame(x = x0 + vx * t, height = h0 + vy * t - g * t^2 / 2)

  at_net <- h0 + vy * (-x0 / vx) - g * (-x0 / vx)^2 / 2
  if (at_net < net_height_centre) {
    arc <- rbind(arc[arc$x < 0, ], data.frame(x = 0, height = at_net))
    return(cbind(shot = label, arc))
  }
  #After the bounce: slower, lower
  vx2 <- vx * keep
  vy2 <- -(vy - g * t_land) * restitution
  t2  <- seq(0, 2 * vy2 / g, length.out = 120)
  bounce <- data.frame(x = max(arc$x) + vx2 * t2, height = vy2 * t2 - g * t2^2 / 2)
  out <- rbind(arc, bounce)
  cbind(shot = label, out[out$x <= runoff_length / 2, ])
}
flights <- rbind(
  flight("Rally ball, 20 m/s at 9°", 20, 9),
  flight("Deep looping ball, 18 m/s at 16°", 18, 16),
  flight("Flat drive, 26 m/s at 5°", 26, 5),
  flight("Into the net, 26 m/s at 3.5°", 26, 3.5)
)
side <- tennis_court_side(max_height = 3) +
  geom_path(data = flights, aes(x = x, y = height, colour = shot), linewidth = 0.8) +
  scale_colour_manual(values = c("#3A86FF", "#2A9D8F", "#FB8500", "#E63946"), name = NULL) +
  theme(legend.position = "bottom") + guides(colour = guide_legend(nrow = 2))
save(side, "tennis_court_side.png", 9, 3)
