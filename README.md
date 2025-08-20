<img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Symbols/Red%20Square.png" alt="Logo" width="100" height="100">

# `roundrect` - Custom Rounded Rectangle Drawing in R

`roundrect` is an R package that allows you to easily draw custom rounded rectangles with individually adjustable corner radii. Unlike the `grid` package's `grid.roundrect()` that applies the same radius to all corners, this package enables you to set different radii for each corner of the rectangle, making it more flexible for various graphical needs.

## Features

- Draw a rounded rectangle with customizable corner radii.
- Easily adjust rectangle position, size, border color, and fill color.
- Control opacity, border width, and border style.
- Straightforward parameter names for easier understanding and use.

## Installation

You can install the package from GitHub using the `devtools` package:

```R
# Install devtools if not already installed
install.packages("devtools")

# Install roundrect from GitHub
devtools::install_github("shahriar-siham/roundrect")
```

## Example

```R
library(roundrect)

round_rect(
  fill = "#e43a59", 
  border = NA, 
  scale = c(0.5, 0.5), 
  corners = c(0.25, 0.05, 0.25, 0.05)
)
```

<p align="center">
  <img src="https://github.com/shahriar-siham/roundrect/blob/main/example_image/roundrect_example_ouput.png" alt="Example: Rounded Rectangle" width="500">
  <br>
</p>

## Integration with ggplot2

`roundrect` also integrates with **ggplot2**, allowing you to draw rounded rectangles directly in plots. Simply use `geom_roundrect()` as a drop-in replacement for `geom_col()`.

```R
library(roundrect)
library(ggplot2)
library(grid)

df <- data.frame(x = c("A", "B", "C"), y = c(3, 5, 2))

ggplot(df, aes(x, y)) + 
  geom_roundrect(fill = grid::linearGradient(c('#ff304e', '#ef407c')), r = 0.075) +
  theme_minimal()
```
<br>

<p align="center">
  <img src="https://github.com/shahriar-siham/roundrect/blob/main/example_image/roundrect_geom_roundrect_preview.png" alt="Example: geom_roundrect() with ggplot2" width="500">
  <br>
</p>

<br>

## Parameters:
- `position`: A vector specifying the x and y positions of the rectangle (default: `c(0.5, 0.5)`).
- `scale`: A vector specifying the width and height of the rectangle (default: `c(1, 1)`).
- `corners`: A vector specifying the radii of the corners (clockwise) (default: `c(0.15, 0.15, 0.15, 0.15)`).
- `opacity`: Opacity of the rectangle (default: `1`).
- `fill`: The fill color of the rectangle (default: `NA`).
- `border`: The border color of the rectangle (default: `"black"`).
- `border_width`: The width of the border (default: `1`).
- `border_type`: The type of the border (e.g., "solid", "dashed") (default: `"solid"`).
- `border_cap`: The style of the border cap (e.g., "round", "butt") (default: `"round"`).
- `output_as_grob`: Whether to return the grob object instead of drawing it (default: `FALSE`).
- `name`: The name of the grob object (optional).

## License

This package is licensed under the MIT License.

