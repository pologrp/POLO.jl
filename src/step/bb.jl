mutable struct BB <: AbstractStep
    xprev::Vector{Float64}
    gprev::Vector{Float64}

    function (::Type{BB})()
        return new()
    end
end

function initialize!(bb::BB,x₀::Vector{Float64})
    bb.xprev = zeros(length(x₀))
    bb.gprev = zeros(length(x₀))
end

function stepsize(bb::BB,klocal::Integer,kglobal::Integer,fval::Real,x::AbstractVector,g::AbstractVector)
    if kglobal == 1
        bb.xprev .= x
        bb.gprev .= g
        return 1.
    end
    s = x - bb.xprev
    y = g - bb.gprev
    η = norm(s,2)^2/(s⋅y)
    bb.xprev .= x
    bb.gprev .= g
    return η
end
