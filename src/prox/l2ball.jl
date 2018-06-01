@with_kw mutable struct L2ballParameters{T <: AbstractFloat} <: AbstractPolicyParameters
    r::T = 1
    c::Vector{T}
end

mutable struct L2ball <: AbstractProx
    params::L2ballParameters{Float64}

    function (::Type{L2ball})(; kwargs...)
        return new(L2ballParameters(; kwargs...))
    end
end

function prox!(l2ball::L2ball,step::Real,xprev::AbstractVector,gcurr::AbstractVector,xcurr::AbstractVector)
    @unpack r,c = l2ball.params
    temp = xprev - step*gcurr
    radius = norm(temp,2)
    scaling = r/max(radius,r)
    # xcurr = c + scaling* ?
end
