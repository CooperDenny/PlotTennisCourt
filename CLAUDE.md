# PlotTennisCourt

R function for plotting a customisable tennis court using ggplot2.

## Functions (in `plot_tennis_court.R`)

- `plot_tennis_court(court_colour, boundary_colour, surface, half, orientation, singles_sticks)` — colours accept any valid R colour string or hex code; `surface` presets ("hard", "clay", "grass") fill any colour left NULL. The first two arguments stay positional and the full-court output must stay unchanged.
- `tennis_serve_zones()` / `tennis_serve_zone_of()` / `tennis_serve_map()` — wide/body/T thirds of the far service boxes; server at the near baseline, deuce box at -x
- `tennis_court_side(max_height, height_scale)` — side view; heights are stretched by `height_scale` and the plot states it

`examples.R` regenerates every image in `images/` (`Rscript examples.R`, under a UTF-8 locale).

## Usage

```r
source("plot_tennis_court.R")
plot_tennis_court(court_colour = "#5f819a", boundary_colour = "#508dba")
```

Returns a ggplot2 object. Can be extended with additional ggplot2 layers.

## Example outputs

See `images/` for examples across different colour schemes (hard court blue, clay red, grass green).

## Geometry

Dimensions are named constants at the top of `plot_tennis_court.R` (ITF Rules of Tennis), and every line is one row of the `court_lines` data frame. Edit the table rather than adding `annotate()` calls. `orientation = "horizontal"` swaps x/y in every table with `swap_xy()`.

## Packages

`ggplot2` (>= 3.4.0) only
