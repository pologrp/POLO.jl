abstract type AbstractBoosting <: AbstractPolicy end

function boost_policy_cwrapper(boosting::B) where B <: AbstractBoosting
    boost_policy = (gprev_b::Ptr{Cdouble},gprev_e::Ptr{Cdouble},gcurr_b::Ptr{Cdouble},boost_data::Ptr{Void}) -> begin
        boost_policy = unsafe_pointer_to_objref(boost_data)::B
        ptrdiff = Int(gprev_e - gprev_b)
        N = divrem(ptrdiff, sizeof(Cdouble))[1]
        gprev = unsafe_wrap(Array, gprev_b, N)
        gcurr = unsafe_wrap(Array, gcurr_b, N)
        method_exists(boost!,(B,Vector{Float64},Vector{Float64})) || error("No defined boost! function for boosting policy ",B)
        boost!(boost_policy, gprev, gcurr)
        return gcurr_b + N
    end
    boost_policy_c = cfunction(boost_policy, Ptr{Cdouble},
                               (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Void}))
    return boost_policy_c
end

module Boosting

using Parameters
using POLO: AbstractBoosting, AbstractPolicyParameters

include("none.jl")
include("momentum.jl")

end
