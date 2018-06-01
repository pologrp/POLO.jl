@with_kw mutable struct ConstantParameters{T <: AbstractFloat} <: AbstractPolicyParameters
    γ::T = 1.
end

struct Constant <: AbstractStep
    params::ConstantParameters{Float64}

    function (::Type{Constant})(; kwargs...)
        return new(ConstantParameters(; kwargs...))
    end
end

function step(constant::Constant,k::Integer,fval::Real,x::AbstractVector,g::AbstractVector)
    return constant.params.γ
end
