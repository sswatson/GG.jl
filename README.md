
# GG.jl

`GG` is a (`ggplot2`)[https://ggplot2.tidyverse.org]-inspired grammar-of-graphics interface to (`Plots.jl`)[https://github.com/JuliaPlots/Plots.jl].
It is designed to allow ggplot2 examples to be translated fairly directly from R to Julia: 

```julia
using GG, RDatasets
iris = dataset("datasets", "iris")
ggplot(data = iris) +
    geom_point(aes(x = :SepalLength,
                   y = :SepalWidth,
                   color = :PetalWidth),
               size = 4)
```

Unprocessed keywords are passed directly to the underlying `Plots` object, so you can mix ggplot2 and Plots features.

`GG` is a work in progress. The currently supported geoms are:

```julia
geom_point
geom_jitter
geom_line
geom_path
geom_step
geom_polygon
geom_ribbon
geom_area
geom_bar
geom_hist
geom_density
geom_text
geom_smooth
```

## Installation

```julia
using Pkg
Pkg.add("https://github.com/sswatson/GG.jl")
```