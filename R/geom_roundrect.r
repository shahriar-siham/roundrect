#' @import ggplot2
#' @import grid

#' @export
geom_roundrect <- function(mapping = NULL, data = NULL,
                           stat = "identity", position = "stack",
                           ...,
                           width = NULL,
                           r = 0.1, # corner radius
                           na.rm = FALSE,
                           show.legend = NA,
                           inherit.aes = TRUE) {
    ggplot2::layer(
        geom = GeomRoundRect, mapping = mapping, data = data, stat = stat,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(
            width = width,
            r = r,
            na.rm = na.rm,
            ...
        )
    )
}

#' @export
GeomRoundRect <- ggplot2::ggproto("GeomRoundRect", ggplot2::Geom,
    required_aes = c("x", "y"),
    default_aes = ggplot2::aes(
        colour = NA, fill = "grey35", linewidth = 0.5, linetype = 1, alpha = 1
    ),
    draw_panel = function(data, panel_params, coord, width = NULL, r = 0.1, na.rm = FALSE) {
        coords <- coord$transform(data, panel_params)

        # compute bar width
        if (is.null(width)) {
            width <- ggplot2::resolution(coords$x, FALSE) * 0.9
        }

        grobs <- lapply(1:nrow(coords), function(i) {
            h <- coords$y[i]
            w <- width

            round_rect(
                position = c(coords$x[i], h / 2), # center of bar
                scale = c(w, h), # width × height
                corners = if (length(r) == 1) rep(r, 4) else r, # rounded corners
                opacity = coords$alpha[i],
                fill = coords$fill[i],
                border = coords$colour[i],
                border_width = coords$linewidth[i],
                border_type = coords$linetype[i],
                output_as_grob = TRUE
            )
        })

        grid::grobTree(do.call(grid::gList, grobs))
    },
    draw_key = ggplot2::draw_key_polygon
)
