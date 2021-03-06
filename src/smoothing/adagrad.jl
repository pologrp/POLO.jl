@with_kw mutable struct AdagradParameters{T <: AbstractFloat} <: AbstractPolicyParameters
    ϵ::T = 1e-6
end

struct Adagrad <: AbstractSmoothing
    params::AdagradParameters{Float64}
    grms::Vector{Float64}

    function (::Type{Adagrad})(; kwargs...)
        return new(AdagradParameters(; kwargs...),Vector{Float64}())
    end
end

function initialize!(adagrad::Adagrad,x₀::Vector{Float64})
    resize!(adagrad.grms,length(x₀))
    adagrad.grms .= zeros(length(x₀))
end

function smooth!(adagrad::Adagrad,klocal::Integer,kglobal::Integer,x::AbstractVector,gprev::AbstractVector,gcurr::AbstractVector)
    @unpack ϵ = adagrad.params
    adagrad.grms .+= gprev .* gprev
    gcurr .= gprev ./ (.√adagrad.grms .+ ϵ)
end
