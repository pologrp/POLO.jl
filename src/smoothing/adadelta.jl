@with_kw mutable struct AdadeltaParameters{T <: AbstractFloat} <: AbstractPolicyParameters
    ρ::T = 0.95
    ϵ::T = 1e-6
end

mutable struct Adadelta <: AbstractSmoothing
    params::AdadeltaParameters{Float64}
    grms::Vector{Float64}
    xrms::Vector{Float64}
    xprev::Vector{Float64}

    function (::Type{Adadelta})(; kwargs...)
        return new(AdadeltaParameters(; kwargs...),Vector{Float64}(),Vector{Float64}(),Vector{Float64}())
    end
end

function initialize!(adadelta::Adadelta,x₀::Vector{Float64})
    adadelta.grms = zeros(length(x₀))
    adadelta.xrms = zeros(length(x₀))
    adadelta.xprev = copy(x₀)
end

function smooth!(adadelta::Adadelta,klocal::Integer,kglobal::Integer,x::AbstractVector,gprev::AbstractVector,gcurr::AbstractVector)
    @unpack ρ,ϵ = adadelta.params
    Δx = x-adadelta.xprev
    adadelta.grms = ρ*adadelta.grms + (1-ρ)*(gprev .* gprev)
    adadelta.xrms = ρ*adadelta.xrms + (1-ρ)*(Δx .* Δx)
    gcurr = gprev * ((.√adadelta.xrms + ϵ) ./ (.√adadelta.grms + ϵ))
    adadelta.xprev[:] = x
end
