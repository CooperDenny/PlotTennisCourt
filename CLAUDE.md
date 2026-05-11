# PlotTennisCourt

R function for plotting a customisable tennis court using ggplot2.

## Function

`plot_tennis_court(court_colour, boundary_colour)` in `plot_tennis_court.R`

Parameters control the court and boundary colours — supports any valid R colour string or hex code.

## Usage

```r
source("plot_tennis_court.R")
plot_tennis_court(court_colour = "#5f819a", boundary_colour = "#508dba")
```

Returns a ggplot2 object. Can be extended with additional ggplot2 layers.

## Example outputs

See `images/` for examples across different colour schemes (hard court blue, clay red, grass green).

## Packages

`ggplot2`
