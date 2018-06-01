@with_kw mutable struct MomentumParameters{T <: AbstractFloat} <: AbstractPolicyParameters
    μ::T = 0.9
    ϵ::T = 1e-3
end

abstract type MomentumTrait end
abstract type Classical <: MomentumTrait end
abstract type Nesterov <: MomentumTrait end

mutable struct Momentum{T} <: AbstractBoosting
    params::MomentumParameters{Float64}
    ν::Vector{Float64}

    function (::Type{Momentum})(::Type{T}; kwargs...) where T <: MomentumTrait
        return new{T}(MomentumParameters(; kwargs...),Vector{Float64}())
    end
end

function initialize!(momentum::Momentum,x₀::Vector{Float64})
    momentum.ν = zeros(length(x₀))
end

params(momentum::Momentum) = momentum.params


function boost!(momentum::Momentum{Classical},gprev::AbstractVector,gcurr::AbstractVector)
    @unpack μ,ϵ = momentum.params
    momentum.ν = μ*momentum.ν+ϵ*gprev
    gurr = momentum.ν
end

function boost!(momentum::Momentum{Nesterov},gprev::AbstractVector,gcurr::AbstractVector)
    @unpack μ,ϵ = momentum.params
    νprev = copy(momentum.ν)
    momentum.ν = μ*νprev+ϵ*gprev
    gurr = μ^2*νprev+(1+μ)*ϵ*gprev
end

Momentum(; kwargs...) = Momentum(Classical; kwargs...)
Nesterov(; kwargs...) = Momentum(Nesterov; kwargs...)
