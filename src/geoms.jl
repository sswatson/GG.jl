

# -- GEOM_POINT ------------------------------------------------
struct GeomPoint <: Geom
    kw::KW
end

geom_point(; kw...) = GeomPoint(kw) 

const _point_keymap =
    KW(:alpha => :markeralpha,
       :color => :markerstrokecolor,
       :fill => :markercolor, 
       :shape => :markershape, 
       :size => :markersize)

const _point_aes_keymap =
    KW(:alpha => KW(:disc => :markeralpha, :cont => :markeralpha), 
       :color => KW(:disc => :markercolor, :cont => :marker_z), 
       :fill => KW(:disc => :markercolor, :cont => :markercolor), 
       :shape => KW(:disc => :markershape), 
       :size => KW(:disc => :markersize, :cont => :markersize))

_expand_args(gg::GGPlot,geom::GeomPoint,facet::Facet) =
    _expand_args(gg, geom, facet, KW(:seriestype => get(geom.kw,:stat,:scatter)), 
                 _point_aes_keymap, _point_keymap)

geom_jitter(args...;kwargs...) = geom_point(args...; stat = :jitter, kwargs...)
#---------------------------------------------------------------

# -- GEOM_LINE -------------------------------------------------
struct GeomLine <: Geom
    kw::KW
end

geom_line(; kw...) = GeomLine(kw) 

const _line_keymap =
    KW(:alpha => :linealpha,
       :color => :linecolor,
       :linetype => :linestyle, 
       :size => :linewidth)

const _line_aes_keymap =
    KW(:alpha => KW(:disc => :linealpha, :cont => :linealpha), 
       :color => KW(:disc => :linecolor, :cont => :line_z), 
       :size => KW(:disc => :linewidth, :cont => :linewidth))

_expand_args(gg::GGPlot,geom::GeomLine,facet::Facet) =
    _expand_args(gg, geom, facet, KW(:seriestype => :line),
                 _line_aes_keymap, _line_keymap)
#---------------------------------------------------------------

# -- GEOM_PATH -------------------------------------------------
struct GeomPath <: Geom
    kw::KW
end

geom_path(; kw...) = GeomPath(kw) 

const _path_keymap =
    KW(:alpha => :linealpha,
       :color => :linecolor,
       :linetype => :linestyle, 
       :size => :linewidth)

const _path_aes_keymap =
    KW(:alpha => KW(:disc => :linealpha, :cont => :linealpha), 
       :color => KW(:disc => :linecolor, :cont => :line_z), 
       :size => KW(:disc => :linewidth, :cont => :linewidth))

_expand_args(gg::GGPlot,geom::GeomPath,facet::Facet) =
    _expand_args(gg, geom, facet, KW(:seriestype => :path),
                 _path_aes_keymap, _path_keymap)
#---------------------------------------------------------------

# -- GEOM_STEP -------------------------------------------------
struct GeomStep <: Geom
    kw::KW
end

"""
Make step plot

```julia
ggplot() + geom_step(aes(x = 1:10, y = 1:10))
```
"""
geom_step(; kw...) = GeomStep(kw) 

const _step_keymap =
    KW(:alpha => :linealpha,
       :color => :linecolor,
       :linetype => :linestyle, 
       :size => :linewidth,
       :direction => :stepdirection)

const _step_aes_keymap =
    KW(:alpha => KW(:disc => :linealpha, :cont => :linealpha), 
       :color => KW(:disc => :linecolor, :cont => :line_z), 
       :size => KW(:disc => :linewidth, :cont => :linewidth))

_expand_args(gg::GGPlot,geom::GeomStep,facet::Facet) =
    _expand_args(gg, geom, facet, KW(:seriestype => :ggstep),
                 _step_aes_keymap, _step_keymap)
#---------------------------------------------------------------

# -- GEOM_POLYGON ----------------------------------------------
struct GeomPolygon <: Geom
    kw::KW
end

"""
    Make a polygon.

```julia
df = DataFrame(x = [0,0,1,0,4,4,5,4], 
     	       y = [0,1,0,0,4,5,4,4], 
               tri = Any[1,1,1,1,2,2,2,2]) # tri specifies which triangle

ggplot(data = df) + geom_polygon(aes(x = :x, y = :y, group = :tri))
ggplot(data = df) + geom_polygon(aes(x = :x, y = :y, linetype = :tri))
```
"""
geom_polygon(; kw...) = GeomPolygon(kw)

const _polygon_keymap =
    KW(:alpha => :fillalpha,
       :fill => :fillcolor,
       :color => :linecolor,
       :linetype => :linestyle, 
       :size => :linewidth)

const _polygon_aes_keymap =
    KW(:group => :group,
       :fill => KW(:disc => :fillcolor, :cont =>:fillcolor),
       :color => KW(:disc => :linecolor, :cont =>:linecolor),
       :linetype => KW(:disc => :linestyle))

_expand_args(gg::GGPlot,geom::GeomPolygon,facet::Facet) =
    _expand_args(gg, geom, facet, KW(:seriestype => :polygon),
                 _polygon_aes_keymap, _polygon_keymap)
#---------------------------------------------------------------

# -- GEOM_RIBBON ------------------------------------------------
struct GeomRibbon <: Geom
    kw::KW
end

geom_ribbon(; kw...) = GeomRibbon(kw) 

const _ribbon_keymap =
    KW(:alpha => :fillalpha,
       :color => :linecolor,
       :fill => :fillcolor, 
       :size => :linewidth)

const _ribbon_aes_keymap =
    KW(:ymin => :ymin, 
       :ymax => :ymax)

_expand_args(gg::GGPlot,geom::GeomRibbon, facet::Facet) =
    _expand_args(gg, geom, facet, KW(:seriestype => :ggribbon),
                 _ribbon_aes_keymap, _ribbon_keymap)
#----------------------------------------------------------------

# -- GEOM_AREA ------------------------------------------------
struct GeomArea <: Geom
    kw::KW
end

geom_area(; kw...) = GeomArea(kw) 

const _area_keymap =
    KW(:alpha => :fillalpha,
       :color => :linecolor,
       :fill => :fillcolor, 
       :size => :linewidth)

const _area_aes_keymap =
    KW()

_expand_args(gg::GGPlot,geom::GeomArea, facet::Facet) =
    _expand_args(gg, geom, facet, KW(:seriestype => :line, :fillrange => 0),
                 _area_aes_keymap, _area_keymap)
#---------------------------------------------------------------

# -- GEOM_BAR --------------------------------------------------
struct GeomBar <: Geom
    kw::KW
end

"""
    geom_bar(aes)

Make a bar plot

ggplot() + 
    geom_bar(aes(x = 1:10, y = rand(10)), label="foo") + 
    geom_bar(aes(x = 1:10, y = rand(10)), label="bar")
"""
geom_bar(; kw...) = GeomBar(kw)

const _bar_keymap =
    KW(:alpha => :fillalpha,
       :fill => :fillcolor,
       :color => :linecolor,
       :linetype => :linestyle, 
       :size => :linewidth)

const _bar_aes_keymap =
    KW(:fill => KW(:disc => :fillcolor, :cont =>:fillcolor),
       :color => KW(:disc => :linecolor, :cont =>:linecolor),
       :linetype => KW(:disc => :linestyle))

_expand_args(gg::GGPlot,geom::GeomBar,facet::Facet) =
    _expand_args(gg, geom, facet, KW(:seriestype => :bar),
                 _bar_aes_keymap, _bar_keymap)
#---------------------------------------------------------------

# -- GEOM_HIST -------------------------------------------------
struct GeomHist <: Geom
    kw::KW
end

"""
    geom_hist(aes)

Make a histogram

```julia
ggplot() + geom_hist(aes(x = randn(100_000)))
```
"""
geom_hist(; kw...) = GeomHist(kw)

const _hist_keymap =
    KW(:alpha => :fillalpha,
       :fill => :fillcolor,
       :color => :linecolor,
       :linetype => :linestyle, 
       :size => :linewidth)

const _hist_aes_keymap =
    KW(:fill => KW(:disc => :fillcolor, :cont =>:fillcolor),
       :color => KW(:disc => :linecolor, :cont =>:linecolor),
       :linetype => KW(:disc => :linestyle))

_expand_args(gg::GGPlot,geom::GeomHist, facet::Facet) =
    _expand_args(gg, geom, facet, KW(:seriestype => :hist),
                 _hist_aes_keymap, _hist_keymap)
#---------------------------------------------------------------

# -- GEOM_DENSITY -------------------------------------------------
struct GeomDensity <: Geom
    kw::KW
end

"""
    geom_density(aes)

Make a one-dimensional density plot.

```julia
df = DataFrame(x = randn(100))
ggplot(data = df) +
    geom_density(aes(x = :x), color = :DarkGreen)
```
"""
geom_density(; kw...) = GeomDensity(kw)

const _density_keymap =
    KW(:alpha => :fillalpha,
       :fill => :fillcolor,
       :color => :linecolor,
       :linetype => :linestyle, 
       :size => :linewidth)

const _density_aes_keymap =
    KW(:fill => KW(:disc => :fillcolor, :cont =>:fillcolor),
       :color => KW(:disc => :linecolor, :cont =>:linecolor),
       :linetype => KW(:disc => :linestyle))

_expand_args(gg::GGPlot,geom::GeomDensity,facet::Facet) =
    _expand_args(gg, geom, facet, KW(:seriestype => :density),
                 _density_aes_keymap, _density_keymap)
#---------------------------------------------------------------

# -- GEOM_TEXT -------------------------------------------------
struct GeomText <: Geom
    kw::KW
end

geom_text(; kw...) = GeomText(kw)

const _text_keymap =
    KW(:label => :ggtext,
       :color => :ggtextcolor,
       :angle => :ggrotation, 
       :family => :fontfamily,
       :hjust => :gghalign, 
       :vjust => :ggvalign,
       :size => :ggfontsize)

const _text_aes_keymap =
    KW(:label => :ggtext,
       :color => :ggtextcolor,
       :angle => :ggrotation, 
       :family => :fontfamily,
       :hjust => :gghalign, 
       :vjust => :ggvalign,
       :size => :ggfontsize)

_expand_args(gg::GGPlot,geom::GeomText,facet::Facet) =
    _expand_args(gg, geom, facet, KW(:seriestype => :ggtext),
                 _text_aes_keymap, _text_keymap) 
#---------------------------------------------------------------

# -- GEOM_SMOOTH -----------------------------------------------
struct GeomSmooth <: Geom
    kw::KW
end


"""
    geom_smooth(aes, method = :loess)

Plot a trend line. Method can be `:lm` for a linear fit or 
`:loess` for a curve.

```julia
ggplot(data = iris, 
       mapping = aes(x = :SepalLength,
                     y = :SepalWidth)) +
    geom_point(size = 2, legend = false) + 
    geom_smooth(size = 2)
```
"""
geom_smooth(; kw...) = GeomSmooth(kw)

const _smooth_keymap =
    KW(:alpha => :linealpha,
       :color => :linecolor,
       :linetype => :linestyle, 
       :size => :linewidth,
       :method => :method)

const _smooth_aes_keymap =
    KW(:alpha => :linealpha,
       :color => :linecolor,
       :linetype => :linestyle, 
       :size => :linewidth)

_expand_args(gg::GGPlot,geom::GeomSmooth,facet::Facet) =
    _expand_args(gg, geom, facet, KW(:seriestype => :ggsmooth),
                 _smooth_aes_keymap, _smooth_keymap)
#---------------------------------------------------------------

# -- GEOM_CONTOUR ----------------------------------------------
struct GeomContour <: Geom
    kw::KW
end

geom_contour(; kw...) = GeomContour(kw)

const _contour_keymap =
    KW(:alpha => :linealpha,
       :color => :linecolor,
       :linetype => :linestyle, 
       :size => :linewidth)

const _contour_aes_keymap =
    KW(:alpha => :linealpha,
       :color => :linecolor,
       :linetype => :linestyle, 
       :size => :linewidth)

_expand_args(gg::GGPlot,geom::GeomContour,facet::Facet) =
    _expand_args(gg, geom, facet, KW(:seriestype => :contour),
                 _contour_aes_keymap, _contour_keymap)
#---------------------------------------------------------------
