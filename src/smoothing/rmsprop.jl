@with_kw mutable struct RMSpropParameters{T <: AbstractFloat} <: AbstractPolicyParameters
    ρ::T = 0.9
    ϵ::T = 1e-6
end

struct RMSprop <: AbstractSmoothing
    params::RMSpropParameters{Float64}
    grms::Vector{Float64}

    function (::Type{RMSprop})(; kwargs...)
        return new(RMSpropParameters(; kwargs...),Vector{Float64}())
    end
end

function initialize!(rmsprop::RMSprop,x₀::Vector{Float64})
    resize!(rmsprop.grms,length(x₀))
    rmsprop.grms .= zeros(length(x₀))
end

function smooth!(rmsprop::RMSprop,klocal::Integer,kglobal::Integer,x::AbstractVector,gprev::AbstractVector,gcurr::AbstractVector)
    @unpack ρ,ϵ = rmsprop.params
    rmsprop.grms .= ρ*rmsprop.grms + (1-ρ)*(gprev .* gprev)
    gcurr .= gprev ./ (.√rmsprop.grms .+ ϵ)
end
