abstract type AbstractProx <: AbstractPolicy end

function prox_policy_cwrapper(prox::P) where P <: AbstractProx
    prox_policy = (step::Cdouble, xprev_b::Ptr{Cdouble},
                   xprev_e::Ptr{Cdouble}, gcurr_b::Ptr{Cdouble}, xcurr_b::Ptr{Cdouble},
                   prox_data::Ptr{Void}) -> begin
                       prox_policy = unsafe_pointer_to_objref(prox_data)::P
                       ptrdiff = Int(xprev_b - xprev_e)
                       N = divrem(ptrdiff, sizeof(Cdouble))[1]
                       xprev = unsafe_wrap(Array, xprev_b, N)
                       gcurr = unsafe_wrap(Array, gcurr_b, N)
                       xcurr = unsafe_wrap(Array, xcurr_b, N)
                       method_exists(prox!,(P,Float64,Vector{Float64},Vector{Float64},Vector{Float64})) || error("No defined prox! function for prox policy ",P)
                       prox!(prox_policy, step, xprev, gcurr, xcurr)
                       return xcurr + N
                   end
    prox_policy_c = cfunction(prox_policy, Ptr{Cdouble},
                              (Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Void}))
    return prox_policy_c
end

module Prox

using Parameters
using POLO: AbstractProx, AbstractPolicyParameters

include("none.jl")
#include("affine.jl")
include("box.jl")
#include("halfspace.jl")
include("l1norm.jl")
#include("l2ball.jl")
#include("orthant.jl")

end
