@with_kw mutable struct HalfspaceParameters{T <: AbstractFloat} <: AbstractPolicyParameters
    α::T = 0.
    a::Vector{T}
end

struct Halfspace <: AbstractProx
    params::HalfspaceParameters{Float64}
    norm::Float64

    function (::Type{Halfspace})(; kwargs...)
        params = HalfspaceParameters(; kwargs...)
        @unpack a = params
        return new(params,a⋅a)
    end
end

function prox!(halfspace::Halfspace,step::Real,xprev::AbstractVector,gcurr::AbstractVector,xcurr::AbstractVector)
    @unpack α,a = halfspace.params
    x = xprev - step*gcurr
    diff = a⋅x - α
    xcurr .= x - (max(diff,zero(eltype(a)))/halfspace.norm)*a
end
