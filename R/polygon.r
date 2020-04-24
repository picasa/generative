# source : https://fronkonstin.com/2019/03/27/drrrawing-with-purrr/

library(tidyverse)

# This function creates the segments of the original polygon
polygon <- function(n) {
  tibble(
    x    = accumulate(1:(n-1), ~.x+cos(.y*2*pi/n), .init = 0),
    y    = accumulate(1:(n-1), ~.x+sin(.y*2*pi/n), .init = 0),
    xend = accumulate(2:n,     ~.x+cos(.y*2*pi/n), .init = cos(2*pi/n)),
    yend = accumulate(2:n,     ~.x+sin(.y*2*pi/n), .init = sin(2*pi/n)))
}

# This function creates segments from some mid-point of the edges
mid_points <- function(d, p, a, i, FUN = ratio_f) {
  d %>% mutate(
    angle=atan2(yend-y, xend-x) + a,
    radius=FUN(i),
    x=p*x+(1-p)*xend,
    y=p*y+(1-p)*yend,
    xend=x+radius*cos(angle),
    yend=y+radius*sin(angle)) %>% 
    select(x, y, xend, yend)
}

# This function connect the ending points of mid-segments
con_points <- function(d) {
  d %>% mutate(
    x=xend,
    y=yend,
    xend=lead(x, default=first(x)),
    yend=lead(y, default=first(y))) %>% 
    select(x, y, xend, yend)
}

# theme
theme_plot <- theme(legend.position  = "none",
      panel.background = element_rect(fill=back_color),
      plot.background  = element_rect(fill=back_color),
      axis.ticks       = element_blank(),
      panel.grid       = element_blank(),
      axis.title       = element_blank(),
      axis.text        = element_blank())

# edges <- 5   # Number of edges of the original polygon
# niter <- 4 # Number of iterations
# pond <- 0.5  # Weight to calculate the point on the middle of each edge
# step  <- 2  # No of times to draw mid-segments before connect ending points
# alph  <- 0.25 # transparency of curves in geom_curve
# angle <- pi/2 # angle of mid-segment with the edge
# curv <- 0   # Curvature of curves
# line_color <- "black" # Color of curves in geom_curve
# back_color <- "white" # Background of the ggplot
# ratio_f <- function(x) {0.2} # To calculate the longitude of mid-segments


edges <- 4   # Number of edges of the original polygon
niter <- 150 # Number of iterations
pond <- 0.22  # Weight to calculate the point on the middle of each edge
step  <- 10  # No of times to draw mid-segments before connect ending points
alph  <- 0.45 # transparency of curves in geom_curve
angle <- 4.78 # angle of mid-segment with the edge
curv <- 0   # Curvature of curves
line_color <- "black" # Color of curves in geom_curve
back_color <- "white" # Background of the ggplot
ratio_f <- function(x) {1/x} # To calculate the longitude of mid-segments

# Generation on the fly of the dataset
df <- accumulate(
  .f = function(old, y) {
    if (y %% step !=0) mid_points(old, pond, angle, y)
    else con_points(old)
  },
  1:niter,.init=polygon(edges)) %>%
  bind_rows() 

# Plot
ggplot(df)+
  geom_curve(
    aes(x=x, y=y, xend=xend, yend=yend),
    curvature = curv, color=line_color, alpha=alph) +
  coord_equal() + theme_plot
  
