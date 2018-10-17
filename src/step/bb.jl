@with_kw mutable struct BBParameters{T <: AbstractFloat} <: AbstractPolicyParameters
    γ₀::T = 1.
end

mutable struct BB <: AbstractStep
    params::BBParameters{Float64}
    xprev::Vector{Float64}
    gprev::Vector{Float64}

    function (::Type{BB})(; kwargs...)
        return new(BBParameters(; kwargs...))
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
        return bb.params.γ₀
    end
    s = x - bb.xprev
    y = g - bb.gprev
    η = norm(s,2)^2/(s⋅y)
    bb.xprev .= x
    bb.gprev .= g
    return η
end
