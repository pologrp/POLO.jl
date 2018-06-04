abstract type AbstractSmoothing <: AbstractPolicy end

function smooth!(smoothing::AbstractSmoothing,x::AbstractVector,gprev::AbstractVector,gcurr::AbstractVector)
    error("No defined smooth! function for smoothing policy ", typeof(smoothing))
end

function smooth_wrapper(k::Cint, xbegin::Ptr{Cdouble},
                        xend::Ptr{Cdouble}, gprev_b::Ptr{Cdouble}, gcurr_b::Ptr{Cdouble},
                        smooth_data::Ptr{Void})::Ptr{Cdouble}
    smooth_policy = unsafe_pointer_to_objref(smooth_data)::AbstractSmoothing
    ptrdiff = Int(xbegin - xend)
    N = divrem(ptrdiff, sizeof(Cdouble))[1]
    x = unsafe_wrap(Array, xbegin, N)
    gprev = unsafe_wrap(Array, gprev_b, N)
    gcurr = unsafe_wrap(Array, gcurr_b, N)
    smooth!(smooth_policy, k, x, gprev, gcurr)
    return gcurr_b + ptrdiff
end

const smoothing_c = cfunction(smooth_wrapper, Ptr{Cdouble},
                              (Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Void}))

module Smoothing

using Parameters
using POLO: AbstractSmoothing, AbstractPolicyParameters
import POLO.smooth!

include("none.jl")
include("adagrad.jl")
include("adadelta.jl")
include("rmsprop.jl")

end
