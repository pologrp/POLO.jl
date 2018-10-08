abstract type AbstractBoosting <: AbstractPolicy end

# function boost!(boosting::AbstractBoosting,gprev::AbstractVector,gcurr::AbstractVector)
#     error("No defined boost! function for boosting policy ", typeof(boosting))
# end

function boost!() end

function boost_wrapper(wid::Cint,klocal::Cint,kglobal::Cint,gprev_b::Ptr{Cdouble},gprev_e::Ptr{Cdouble},gcurr_b::Ptr{Cdouble},boost_data::Ptr{Cvoid})
    boost_policy = unsafe_pointer_to_objref(boost_data)::AbstractBoosting
    ptrdiff = Int(gprev_e - gprev_b)
    N = divrem(ptrdiff, sizeof(Cdouble))[1]
    gprev = unsafe_wrap(Array, gprev_b, N)
    gcurr = unsafe_wrap(Array, gcurr_b, N)
    boost!(boost_policy, wid, klocal, kglobal, gprev, gcurr)
    return gcurr_b + ptrdiff
end

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
