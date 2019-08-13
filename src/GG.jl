module GG

using Reexport
@reexport using RecipesBase 
@reexport using StatsPlots
@reexport using DataFrames
import Base: +
import Random: MersenneTwister
import Loess

export
    ggplot,
    ggsave,
    aes, 
    geom_point,
    geom_path, 
    geom_line,
    geom_polygon,
    geom_ribbon,
    geom_area,
    geom_bar,
    geom_hist,
    geom_density,
    geom_text,
    geom_jitter,
    geom_step,
    geom_smooth,
    facet_grid,
    facet_wrap

# -- DEFAULTS --------------------------------------------------

const _default_markershapes = [:circle,
                               :utriangle,
                               :rect,
                               :diamond,
                               :hexagon]

_get_markershapes(shapelist::Vector{Symbol},n::Integer) =
    permutedims([shapelist[mod1(k,length(shapelist))] for k=1:n])
_get_markershapes(n::Integer) = _get_markershapes(_default_markershapes, n)

const _default_linestyles = [:solid, :dash, :dot, :dashdot, :dashdotdot]

_get_linestyles(stylelist::Vector{Symbol},n::Integer) =
    permutedims([stylelist[mod1(k,length(stylelist))] for k=1:n])
_get_linestyles(n::Integer) = _get_linestyles(_default_linestyles, n)

_get_sizes(n::Integer) = permutedims(range(0.25,stop=1,length=n))

_get_alphas(n::Integer) = permutedims(range(0.05,stop=1,length=n))

_get_colors(palette,bg,n) = Plots.get_color_palette(palette,bg,n)
_get_colors(n::Integer) = _get_colors(:auto,colorant"white",n)

const _default_value_funcs =
    KW(:markeralpha => _get_alphas,
       :markerstrokecolor => _get_colors,
       :markercolor => _get_colors,
       :markershape => _get_markershapes,
       :markersize => _get_sizes, 
       :linecolor => _get_colors,
       :linewidth => _get_sizes,
       :linealpha => _get_alphas,
       :linestyle => _get_linestyles)

# -- GGPLOT ----------------------------------------------------

abstract type Geom end

struct Layer
    kw::KW
end

struct Aesthetic
    kw::KW
end

struct Theme
    kw::KW
end

struct Facet
    kw::KW
end

struct GGPlot
    data::Union{Missing, AbstractDataFrame}
    aes::Union{Missing, Aesthetic}
    geoms::Vector{<:Geom}
    theme::Theme
    facet::Facet
end

Aesthetic(;kw...) = Aesthetic(kw)
Aesthetic(s::Symbol,t::Symbol) = Aesthetic(x = s, y = t)
const aes = Aesthetic

Theme(;kw...) = Theme(kw)
Facet(;kw...) = Facet(kw)
const theme = Theme

"""
    ggplot(data, mapping)

Create a `GGPlot` object based on the DataFrame `data`, 
with the mapping `mapping` (optional)

```julia
ggplot(data = iris, 
       mapping = aes(x = :SepalLength, y = :SepalWidth)) + 
    geom_point()
```
"""
function ggplot(;data = missing,
                mapping = missing) 
    GGPlot(data, mapping, Geom[], Theme(), Facet())
end

ggplot(data::AbstractDataFrame, mapping = missing) =
    ggplot(data = data, mapping = mapping)

function _iscontinuous(V::AbstractVector)
    eltype(V) <: Number
end

# --------------------------------------------------------------


# -- TRANSLATING SYMBOLS TO VECTORS ----------------------------

"""
Return the data frame associated with a (GGPlot, Geom) pair
"""
function _df(gg::GGPlot, g::Geom)
    something(get(g.kw,:data,nothing),
              ismissing(gg.data) ? nothing : gg.data,
              missing)
end

"""
Expand `S` to a vector in the context of the data frame `df`, if possible. 
"""
function _symbol_to_vec(df::Union{Missing,AbstractDataFrame}, S)
    if ismissing(df) || !(S in names(df))
        S
    else
        df[S]
    end
end

"""
Map ggplot arguments to corresponding Plots.jl arguments
"""
function _expand_args(gg::GGPlot,
                      geom::Geom,
                      facet::Facet,
                      default_kw::KW,
                      aes_keymap::KW,
                      keymap::KW)
    args = KW()
    kw = default_kw
    df = _df(gg,geom)
    grouping_attributes = Pair{Symbol,Any}[]
    if !(:mapping in keys(geom.kw)) && !ismissing(gg.aes)
        geom.kw[:mapping] = gg.aes
    end
    for (k,v) in geom.kw
        if k == :mapping
            for (aes_k,aes_v) in v.kw
                aes_vector = _symbol_to_vec(df,aes_v) 
                key = get(aes_keymap, aes_k, aes_k)
                if key in (:x, :y, :z)
                    args[key] = aes_vector
                    if isa(aes_v, Symbol)
                        kw[Symbol("$(key)label")] = string(aes_v)
                    end
                elseif isa(key, Symbol)
                    kw[key] = aes_vector
                elseif isa(key, KW)
                    if _iscontinuous(aes_vector)
                        kw[key[:cont]] = aes_vector
                    else
                        push!(grouping_attributes, key[:disc] => aes_vector)
                    end
                else
                    @error("Unsupported type in _expand_args: $key has type $(typeof(key))")
                end
            end
        else
            kw[get(keymap, k, k)] = _symbol_to_vec(df,v)
        end
    end
    merge!(kw,_process_grouping_attributes(grouping_attributes))
    if isnonempty(facet)
        kw[:group], kw[:layout] = facet_regroup(get(kw, :group, ()), df, facet)
    end
    skipmissing(get(args,s,missing) for s in (:x, :y, :z)), kw
end

"""
Handle attribute combinations which must be packaged and passed
to the `group` Plots.jl attribute. 
"""
function _process_grouping_attributes(kv_pairs)
    length(kv_pairs) == 0 && return Dict()
    kw = KW()
    vectors = [vector for (key,vector) in kv_pairs]
    kw[:group] = tuple(vectors...)
    vs = map(tuple, vectors...)
    groupLabels = sort(collect(unique(vs)))
    indexdicts = Dict(k => Dict(map(reverse,enumerate(sort(unique(v))))) for (k,v) in kv_pairs)
    for (k,v) in kv_pairs
        if !(k in keys(_default_value_funcs))
            error("$k missing from _default_value_funcs")
        end
    end
    styledicts = Dict(k => _default_value_funcs[k](length(indexdicts[k])) for (k,v) in kv_pairs)
    for (i,(key, vector)) in enumerate(kv_pairs)
        kw[key] = permutedims([styledicts[key][indexdicts[key][g[i]]] for g in groupLabels])
    end
    kw
end

# ALL GEOMS ----------------------------------------------------

include("geoms.jl")
include("stats.jl")
include("facets.jl")
include("recipes.jl")

for geom in (:geom_point,
             :geom_line,
             :geom_path, 
             :geom_polygon,
             :geom_ribbon,
             :geom_area,
             :geom_bar,
             :geom_hist,
             :geom_density,
             :geom_text,
             :geom_jitter,
             :geom_step,
             :geom_smooth)
    @eval function $geom(aes;kw...)
        $geom(mapping=aes;kw...)
    end
end

#---------------------------------------------------------------

# PLOT DISPLAY -------------------------------------------------

function +(gg::GGPlot, geom::Geom)
    GGPlot(gg.data, gg.aes, vcat(gg.geoms,geom), gg.theme, gg.facet)
end

function +(gg::GGPlot, theme::Theme)
    GGPlot(gg.data, gg.aes, gg.geoms, Theme(merge(gg.theme.kw,theme.kw)), gg.facet)
end

function +(gg::GGPlot, facet::Facet)
    GGPlot(gg.data, gg.aes, gg.geoms, gg.theme, facet)
end

function StatsPlots.plot(gg::GGPlot)
    p = plot()
    for (i,geom) in enumerate(gg.geoms)
        args, kw = _expand_args(gg,geom,gg.facet)
        if i == 1
            p = plot(args...;kw...)
        else
            plot!(p, args...; kw...)
        end
    end
    plot!(p,gg.theme.kw...)
    p
end

Base.display(gg::GGPlot) = display(plot(gg))

Base.show(io::IO, mime::MIME"image/svg+xml", gg::GGPlot) = show(io, mime, plot(gg))

#---------------------------------------------------------------

# MISCELLANEOUS ------------------------------------------------


"""
    ggsave(filename, plot, width, height)

Save `plot` to disk at location `filename`. Optionally specify width 
and height.

```julia
ggsave("my-figure.svg", ggplot() + geom_point(x = 1:10, y = 1:10))
```
"""
function ggsave(filename; gg = nothing, width = nothing, height = nothing)
    if gg isa Nothing
        gg = current()
    end
    if width isa Nothing && height isa Nothing
        Plots.savefig(plot(gg), filename)
    else
        Plots.savefig(plot(gg), filename, size = (width, height))
    end
end


ggsave(filename, gg) = ggsave(filename, gg = gg)

#---------------------------------------------------------------

end # module
