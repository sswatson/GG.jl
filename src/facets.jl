

# -- FACETS ----------------------------------------------------

struct Formula
    LHS::Symbol
    RHS::Symbol
end

import Base.~
~(LHS::Symbol, RHS::Symbol) = Formula(LHS, RHS)
~(RHS::Symbol) = Formula(Symbol(), RHS)


function facet_grid(formula::Formula)
    Facet(LHS = formula.LHS, RHS = formula.RHS, facet_type = :grid, link = :all)
end

function facet_wrap(formula::Formula)
    Facet(LHS = formula.LHS, RHS = formula.RHS, facet_type = :wrap, link = :all)
end

# --------------------------------------------------------------


# -- UTILS -----------------------------------------------------

function isnonempty(facet::Facet)
    get(facet.kw, :LHS, Symbol()) ≠ Symbol() || get(facet.kw, :RHS, Symbol()) ≠ Symbol()
end

function facet_regroup(group, df::DataFrame, facet::Facet)
    if get(facet.kw, :RHS, Symbol()) == :.
        n = length(unique(df[facet.kw[:LHS]]))
        group = (group..., df[facet.kw[:LHS]])
        layout = (n, 1)
    elseif get(facet.kw, :LHS, Symbol()) ∈ (:., Symbol())
        n = length(unique(df[facet.kw[:RHS]]))
        group = (group..., df[facet.kw[:RHS]])
        layout = facet.kw[:facet_type] == :grid ? (1, n) : n
    else
        group = (group..., df[get(facet.kw, :LHS)], df[get(facet.kw, :RHS)])
        layout = map(length∘unique, (df[get(facet.kw, :LHS)], df[get(facet.kw, :RHS)]))
    end
    group, layout
end

# --------------------------------------------------------------
