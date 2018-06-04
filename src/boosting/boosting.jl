abstract type AbstractBoosting <: AbstractPolicy end

# function boost!(boosting::AbstractBoosting,gprev::AbstractVector,gcurr::AbstractVector)
#     error("No defined boost! function for boosting policy ", typeof(boosting))
# end

function boost!() end

function boost_wrapper(gprev_b::Ptr{Cdouble},gprev_e::Ptr{Cdouble},gcurr_b::Ptr{Cdouble},boost_data::Ptr{Void})
    boost_policy = unsafe_pointer_to_objref(boost_data)::AbstractBoosting
    ptrdiff = Int(gprev_e - gprev_b)
    N = divrem(ptrdiff, sizeof(Cdouble))[1]
    gprev = unsafe_wrap(Array, gprev_b, N)
    gcurr = unsafe_wrap(Array, gcurr_b, N)
    boost!(boost_policy, gprev, gcurr)
    return gcurr_b + ptrdiff
end

const boosting_c = cfunction(boost_wrapper, Ptr{Cdouble},
                             (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Void}))

module Boosting

using Parameters
using POLO: AbstractBoosting, AbstractPolicyParameters
import POLO: initialize!, boost!

function initialize!(policy::AbstractBoosting,x₀::Vector{Float64})
    nothing
end

include("none.jl")
include("momentum.jl")

end
