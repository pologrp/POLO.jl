@with_kw mutable struct BoxParameters{T <: AbstractFloat} <: AbstractPolicyParameters
    l::Vector{T}
    u::Vector{T}
end

mutable struct Box <: AbstractProx
    params::BoxParameters{Float64}

    function (::Type{Box})(; kwargs...)
        return new(BoxParameters(; kwargs...))
    end
end

function prox!(box::Box,step::Real,xprev::AbstractVector,gcurr::AbstractVector,xcurr::AbstractVector)
    @unpack l, u = box.params
    temp = xprev - step*gcurr
    xcurr .= min.(max.(temp, l), u)
end
