@with_kw mutable struct L1normParameters{T <: AbstractFloat} <: AbstractPolicyParameters
    λ::T = 1
end

mutable struct L1norm <: AbstractProx
    params::L1normParameters{Float64}

    function (::Type{L1norm})(; kwargs...)
        return new(L1normParameters(; kwargs...))
    end
end

function prox!(l1norm::L1norm,step::Real,xprev::AbstractVector,gcurr::AbstractVector,xcurr::AbstractVector)
    @unpack λ = l1norm.params
    xval = xprev - step*gcurr
    temp = max.(abs.(xval) .- λ*step, zeros(length(xprev)))
    xcurr .= temp
    xcurr[xval .< 0] *= -1
end
