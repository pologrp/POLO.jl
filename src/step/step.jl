abstract type AbstractStep <: AbstractPolicy end

function step_policy_cwrapper(step::S) where S <: AbstractStep
    step_policy = (k::Cint, fval::Cdouble, xbegin::Ptr{Cdouble},
                   xend::Ptr{Cdouble}, gbegin::Ptr{Cdouble},
                   step_data::Ptr{Void}) -> begin
                       step_policy = unsafe_pointer_to_objref(step_data)::S
                       ptrdiff = Int(xend - xbegin)
                       N = divrem(ptrdiff, sizeof(Cdouble))[1]
                       x = unsafe_wrap(Array, xbegin, N)
                       g = unsafe_wrap(Array, gbegin, N)
                       method_exists(step,(S,Int,Float64,Vector{Float64},Vector{Float64})) || error("No defined step function for step policy ",S)
                       return step(step_policy, k, fval, x, g)
                   end
    step_policy_c = cfunction(step_policy, Cdouble,
                              (Cint, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Void}))
    return step_policy_c
end

module Step

using Parameters
using POLO: AbstractStep, AbstractPolicyParameters

include("constant.jl")
include("decreasing.jl")

end
