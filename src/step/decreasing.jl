@with_kw mutable struct DecreasingParameters{T <: AbstractFloat} <: AbstractPolicyParameters
    γ::T = 1.
end

struct Decreasing <: AbstractStep
    params::ConstantParameters{Float64}

    function (::Type{Decreasing})(; kwargs...)
        return new(DecreasingParameters(; kwargs...))
    end
end

function stepsize(decreasing::Decreasing,k::Integer,fval::Real,x::AbstractVector,g::AbstractVector)
    @unpack γ = decreasing.params
    return γ/√k
end
