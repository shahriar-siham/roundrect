#' @import grid
#' @import ggplot2

# Function to generate a single arc (given start and end angles)
generate_arc <- function(
    center,
    radius,
    start_angle,
    end_angle,
    n_points = 20) {
  angles <- seq(start_angle, end_angle, length.out = n_points)
  x <- center[1] + radius * cos(angles)
  y <- center[2] + radius * sin(angles)
  list(x = x, y = y)
}

# Function to create a rounded rectangle with absolute units for radii
rounded_rect_grob <- function(
    x = 0.5,
    y = 0.5, width = 1,
    height = 1,
    r_tl = unit(0.1, "snpc"),
    r_tr = unit(0.1, "snpc"),
    r_br = unit(0.1, "snpc"),
    r_bl = unit(0.1, "snpc"),
    just = "centre",
    gp = gpar(),
    name = NULL) {
  # Ensure all inputs are units
  x <- unit(x, "npc")
  y <- unit(y, "npc")
  width <- unit(width, "npc")
  height <- unit(height, "npc")

  # Adjust x and y based on justification
  just <- valid.just(just)
  x <- x - width * just[1]
  y <- y - height * just[2]

  # Define rectangle edges
  left <- x
  right <- x + width
  bottom <- y
  top <- y + height

  # Define centers of corner arcs
  centers <- list(
    tl = unit.c(left + r_tl, top - r_tl),
    tr = unit.c(right - r_tr, top - r_tr),
    br = unit.c(right - r_br, bottom + r_br),
    bl = unit.c(left + r_bl, bottom + r_bl)
  )

  # Generate arc coordinates for each corner
  arc_tl <- generate_arc(centers$tl, r_tl, pi / 2, pi)
  arc_tr <- generate_arc(centers$tr, r_tr, 0, pi / 2)
  arc_br <- generate_arc(centers$br, r_br, 3 * pi / 2, 2 * pi)
  arc_bl <- generate_arc(centers$bl, r_bl, pi, 3 * pi / 2)

  # Define the straight lines
  line_top_x <- unit.c(left + r_tl, right - r_tr)
  line_top_y <- unit.c(top, top)

  line_right_x <- unit.c(right, right)
  line_right_y <- unit.c(top - r_tr, bottom + r_br)

  line_bottom_x <- unit.c(right - r_br, left + r_bl)
  line_bottom_y <- unit.c(bottom, bottom)

  line_left_x <- unit.c(left, left)
  line_left_y <- unit.c(bottom + r_bl, top - r_tl)

  # Combine all path points
  path_x <- unit.c(
    line_top_x,
    arc_tl$x,
    line_left_x,
    arc_bl$x,
    line_bottom_x,
    arc_br$x,
    line_right_x,
    arc_tr$x
  )
  path_y <- unit.c(
    line_top_y,
    arc_tl$y,
    line_left_y,
    arc_bl$y,
    line_bottom_y,
    arc_br$y,
    line_right_y,
    arc_tr$y
  )

  # Create the grob
  pathGrob(
    x = path_x, y = path_y,
    id = rep(1, length(path_x)),
    rule = "evenodd",
    gp = gp,
    name = name
  )
}

#' Draw Rounded Rectangles with Independent Corner Radii
#'
#' An improved version of the `grid` package's rounded rectangles, allowing each corner to have a different radius instead of a uniform one. This package also provides more intuitive parameter names for easier usage. Customize fill color, border properties, opacity, and more with a simple function call.
#'
#' @param position A vector of two numbers specifying the center position (x, y) of the rectangle.
#' @param scale A vector of two numbers specifying the width and height of the rectangle.
#' @param corners A vector of four numbers setting the corner roundness, starting from the top-left and moving clockwise.
#' @param opacity A number between 0 and 1 controlling the transparency of the rectangle (1 is fully visible, 0 is completely invisible).
#' @param fill A color name or hex code for the rectangle's fill color.
#' @param border A color name or hex code for the rectangle's border.
#' @param border_width A number defining the thickness of the border.
#' @param border_type The style of the border, such as "solid" or "dashed".
#' @param border_cap The shape of the border ends, such as "round" or "butt".
#' @param output_as_grob If TRUE, returns the rectangle as a grob (graphical object) instead of drawing it.
#' @param name A name for the graphical object (optional).
#'
#' @return If `output_as_grob` is TRUE, returns a grob object representing the rectangle. Otherwise, it draws the rectangle and returns nothing.
#'
#' @examples
#' round_rect(
#'   position = c(0.5, 0.5),
#'   scale = c(0.5, 0.5),
#'   corners = c(0.25, 0.15, 0.25, 0.15),
#'   opacity = 0.5,
#'   fill = NA,
#'   border = "black",
#'   border_width = 2,
#'   border_type = "solid"
#' )
#'
#' @export
round_rect <- function(
    position = c(0.5, 0.5),
    scale = c(1, 1),
    corners = c(0.15, 0.15, 0.15, 0.15),
    opacity = 1,
    fill = NA,
    border = "black",
    border_width = 1,
    border_type = "solid",
    border_cap = "round",
    gradient_type = "linear",
    gradient_stops = NULL,
    output_as_grob = FALSE,
    name = NULL) {
  if (!is.numeric(corners) || length(corners) != 4) {
    stop("Input 'corners' must be a numeric vector of exactly 4 elements.")
  }

  if (!is.numeric(position) || length(position) != 2) {
    stop("Input 'position' must be a numeric vector of exactly 2 elements.")
  }

  if (!is.numeric(scale) || length(scale) != 2) {
    stop("Input 'scale' must be a numeric vector of exactly 2 elements.")
  }

  if (length(fill) == 1 && is.na(fill)) {
    fill_value <- NA
  } else if (length(fill) == 1) {
    fill_value <- fill
  } else {
    if (is.null(gradient_stops)) {
      gradient_stops <- seq(0, 1, length.out = length(fill))
    }

    if (gradient_type == "linear") {
      fill_value <- linearGradient(
        colours = fill,
        stops = gradient_stops,
        x1 = 0, y1 = 0,
        x2 = 0, y2 = 1,
        default.units = "snpc"
      )
    } else if (gradient_type == "radial") {
      fill_value <- radialGradient(
        colours = fill,
        stops = gradient_stops
      )
    } else {
      stop("Unknown gradient_type. Gradients must be 'linear' or 'radial'.")
    }
  }

  # Position
  x <- position[1]
  y <- position[2]

  # Scale
  width <- scale[1]
  height <- scale[2]

  # Corners (clockwise)
  top_left <- corners[1]
  top_right <- corners[2]
  bottom_right <- corners[3]
  bottom_left <- corners[4]

  # Proportional clamping of corner radii
  ratios <- c(
    if (top_left + top_right > 0) width / (top_left + top_right) else 1,
    if (bottom_left + bottom_right > 0) width / (bottom_left + bottom_right) else 1,
    if (top_left + bottom_left > 0) height / (top_left + bottom_left) else 1,
    if (top_right + bottom_right > 0) height / (top_right + bottom_right) else 1
  )
  s <- min(1, ratios, na.rm = TRUE)

  top_left <- top_left * s
  top_right <- top_right * s
  bottom_right <- bottom_right * s
  bottom_left <- bottom_left * s

  grob <- rounded_rect_grob(
    x = x,
    y = y,
    width = width,
    height = height,
    r_tl = unit(top_left, "snpc"), r_tr = unit(top_right, "snpc"),
    r_bl = unit(bottom_left, "snpc"), r_br = unit(bottom_right, "snpc"),
    gp = gpar(
      alpha = opacity,
      fill = fill_value,
      col = border,
      lwd = border_width,
      lty = border_type,
      lineend = border_cap
    ),
    name = name
  )

  if (output_as_grob) {
    return(grob)
  } else {
    grid.draw(grob)
  }
}
