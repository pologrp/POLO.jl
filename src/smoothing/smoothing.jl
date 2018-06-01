abstract type AbstractSmoothing <: AbstractPolicy end

function smooth_policy_cwrapper(step::S) where S <: AbstractSmoothing
    smooth_policy = (k::Cint, xbegin::Ptr{Cdouble},
                     xend::Ptr{Cdouble}, gprev_b::Ptr{Cdouble}, gcurr_b::Ptr{Cdouble},
                     step_data::Ptr{Void}) -> begin
                         smooth_policy = unsafe_pointer_to_objref(step_data)::S
                         ptrdiff = Int(xbegin - xend)
                         N = divrem(ptrdiff, sizeof(Cdouble))[1]
                         x = unsafe_wrap(Array, xbegin, N)
                         gprev = unsafe_wrap(Array, gprev_b, N)
                         gcurr = unsafe_wrap(Array, gcurr_b, N)
                         method_exists(smooth!,(S,Int,Vector{Float64},Vector{Float64},Vector{Float64})) || error("No defined smooth! function for smoothing policy ",S)
                         smooth!(smooth_policy, k, x, gprev, gcurr)
                         return gcurr + N
                     end
    smooth_policy_c = cfunction(smooth_policy, Ptr{Cdouble},
                              (Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Void}))
    return smooth_policy_c
end

module Smoothing

using Parameters
using POLO: AbstractSmoothing, AbstractPolicyParameters

include("none.jl")
include("adagrad.jl")
include("adadelta.jl")
include("rmsprop.jl")

end
