abstract type AbstractProx <: AbstractPolicy end

# function prox!(prox::AbstractProx,step::Real,xprev::AbstractVector,gcurr::AbstractVector,xcurr::AbstractVector)
#     error("No defined prox! function for prox policy ", typeof(prox))
# end

function prox!() end

function prox_wrapper(step::Cdouble, xprev_b::Ptr{Cdouble},
                      xprev_e::Ptr{Cdouble}, gcurr_b::Ptr{Cdouble}, xcurr_b::Ptr{Cdouble},
                      prox_data::Ptr{Cvoid})::Ptr{Cdouble}
    prox_policy = unsafe_pointer_to_objref(prox_data)::AbstractProx
    ptrdiff = Int(xprev_e - xprev_b)
    N = divrem(ptrdiff, sizeof(Cdouble))[1]
    xprev = unsafe_wrap(Array, xprev_b, N)
    gcurr = unsafe_wrap(Array, gcurr_b, N)
    xcurr = unsafe_wrap(Array, xcurr_b, N)
    prox!(prox_policy, step, xprev, gcurr, xcurr)
    return xcurr_b + ptrdiff
end

module Prox

using LinearAlgebra
using Parameters
using POLO: AbstractProx, AbstractPolicyParameters
import POLO: initialize!, prox!

function initialize!(policy::AbstractProx,x₀::Vector{Float64})
    nothing
end

include("none.jl")
include("affine.jl")
include("box.jl")
include("halfspace.jl")
include("l1norm.jl")
include("l2ball.jl")
include("orthant.jl")

end
