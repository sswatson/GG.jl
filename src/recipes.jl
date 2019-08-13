
@recipe function f(::Type{Val{:ggribbon}}, x, y, z)
    seriestype := :polygon
    if plotattributes[:ymin] isa Number
        plotattributes[:ymin] = fill(plotattributes[:ymin],length(x))
    end
    if plotattributes[:ymax] isa Number
        plotattributes[:ymax] = fill(plotattributes[:ymax],length(x))
    end
    x := [x; reverse(x); first(x)]
    y := [plotattributes[:ymin]; reverse(plotattributes[:ymax]); first(plotattributes[:ymin])]
    delete!(plotattributes,:ymin)
    delete!(plotattributes,:ymax)
    ()
end

_vectorify(x,n) = x isa Vector ? x : fill(x,n)

@recipe function f(::Type{Val{:ggtext}}, x, y, z)
    n = length(x)
    :ggtextcolor --> :black
    :ggrotation --> 0.0
    :ggfontfamily --> "sans-serif"
    :gghalign --> :hcenter
    :ggvalign --> :vcenter
    :ggfontsize --> 14
    :ggtextcolor := _vectorify(plotattributes[:ggtextcolor],n)
    :ggrotation := float(_vectorify(plotattributes[:ggrotation],n))
    :ggfontfamily := _vectorify(plotattributes[:ggfontfamily],n)
    :gghalign := _vectorify(plotattributes[:gghalign],n)
    :ggvalign := _vectorify(plotattributes[:ggvalign],n)
    :ggfontsize := _vectorify(plotattributes[:ggfontsize],n)
    if !(plotattributes[:ggtextcolor] isa Vector)
        :ggtextcolor := fill(plotattributes[:ggtextcolor], length(plotattributes[:x]))
    end
    plotattributes[:annotations] = [(a,b,text(s,p1,p2,p3,p4,p5,p6)) for (a,b,s,p1,p2,p3,p4,p5,p6) in
                                    zip(plotattributes[:x],
                                        plotattributes[:y],
                                        plotattributes[:ggtext],
                                        plotattributes[:ggtextcolor],
                                        plotattributes[:ggrotation],
                                        plotattributes[:ggfontfamily],
                                        plotattributes[:gghalign],
                                        plotattributes[:ggvalign],
                                        plotattributes[:ggfontsize])]
    
    for s in (:ggtext, :ggtextcolor, :ggrotation, :ggfontfamily, :gghalign, :ggvalign, :ggfontsize)
        delete!(plotattributes,s)
    end
    xlims := extrema(plotattributes[:x])
    ylims := extrema(plotattributes[:y])
    seriestype := :scatter
    legend --> false
    x := []
    y := []
    z := nothing
    ()
end

@recipe function f(::Type{Val{:ggstep}}, x, y, z)
    :stepdirection --> :hv
    if plotattributes[:stepdirection] == :hv
        seriestype := :steppost
    elseif plotattributes[:stepdirection] == :vh 
        seriestype := :steppre
    else
        error("geom_step direction should be :hv or :vh")
    end
    delete!(plotattributes, :stepdirection)
    ()
end

@recipe function f(::Type{Val{:jitter}}, x, y, z; ϵ=0.01)
    seriestype := :scatter
    delete!(plotattributes,:stat)
    R = MersenneTwister(0) 
    if !isa(x,Nothing)
        a,b = extrema(x)
        x := x + ϵ*(b-a)*randn(R,length(x))
    end
    if !isa(y,Nothing)
        a,b = extrema(y)
        y := y + ϵ*(b-a)*randn(R,length(y))
    end
    if !isa(z,Nothing)
        a,b = extrema(z) 
        z := z + ϵ*(b-a)*randn(R,length(z))
    end
    ()
end

@recipe function f(::Type{Val{:ggsmooth}}, x, y, z)
    seriestype := :line
    method --> :loess
    if plotattributes[:method] == :lm
        β, α = convert(Matrix{Float64}, [x ones(length(x))]) \ convert(Vector{Float64}, y)
        u = [Plots.ignorenan_minimum(x), Plots.ignorenan_maximum(x)]
        x := u
        y := β .* u .+ α
    elseif plotattributes[:method] == :loess
        model = Loess.loess(x,y)
        u = range(Plots.ignorenan_minimum(x), stop = Plots.ignorenan_maximum(x), length = 250)
        x := u
        y := Loess.predict(model, u)
    else
        @warn("Smooth method should be :lm or :loess")
    end
    delete!(plotattributes, :method)
    ()
end
