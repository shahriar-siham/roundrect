#' @import grid
library(grid)

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

# Function to check if any pair of radii exceeds the limit
check_condition <- function(r1, r2, side_length) {
  r1 + r2 > side_length
}

# Function to adjust radii proportionally
adjust_radii <- function(r1, r2, side_length) {
  if (check_condition(r1, r2, side_length)) {
    scale_factor <- side_length / (r1 + r2)
    r1 <- r1 * scale_factor
    r2 <- r2 * scale_factor
  }
  list(r1 = r1, r2 = r2)
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

  # Iteratively adjust radii until all pairs satisfy the condition
  while (TRUE) {
    condition_top <- check_condition(top_left, top_right, width)
    condition_right <- check_condition(top_right, bottom_right, height)
    condition_bottom <- check_condition(bottom_right, bottom_left, width)
    condition_left <- check_condition(bottom_left, top_left, height)

    if (
      !condition_top &&
        !condition_right &&
        !condition_bottom &&
        !condition_left
    ) {
      break
    }

    # Adjust radii for all pairs in a single step
    adjusted_top <- adjust_radii(top_left, top_right, width)
    adjusted_right <- adjust_radii(top_right, bottom_right, height)
    adjusted_bottom <- adjust_radii(bottom_right, bottom_left, width)
    adjusted_left <- adjust_radii(bottom_left, top_left, height)

    # Update radii after all adjustments
    top_left <- adjusted_top$r1
    top_right <- adjusted_top$r2
    top_right <- adjusted_right$r1
    bottom_right <- adjusted_right$r2
    bottom_right <- adjusted_bottom$r1
    bottom_left <- adjusted_bottom$r2
    bottom_left <- adjusted_left$r1
    top_left <- adjusted_left$r2
  }

  grob <- rounded_rect_grob(
    x = x,
    y = y,
    width = width,
    height = height,
    r_tl = unit(top_left, "snpc"), r_tr = unit(top_right, "snpc"),
    r_bl = unit(bottom_left, "snpc"), r_br = unit(bottom_right, "snpc"),
    gp = gpar(
      alpha = opacity,
      fill = fill,
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
