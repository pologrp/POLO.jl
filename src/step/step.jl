abstract type AbstractStep <: AbstractPolicy end

# function stepsize(step::AbstractStep,k::Integer,fval::Real,x::AbstractVector,g::AbstractVector)
#     error("No defined step function for step policy ", typeof(step))
# end

function stepsize() end

function step_wrapper(k::Cint, fval::Cdouble, xbegin::Ptr{Cdouble},
                      xend::Ptr{Cdouble}, gbegin::Ptr{Cdouble},
                      step_data::Ptr{Void})
    step_policy = unsafe_pointer_to_objref(step_data)::AbstractStep
    ptrdiff = Int(xend - xbegin)
    N = divrem(ptrdiff, sizeof(Cdouble))[1]
    x = unsafe_wrap(Array, xbegin, N)
    g = unsafe_wrap(Array, gbegin, N)
    return stepsize(step_policy, k, fval, x, g)
end

const step_c = cfunction(step_wrapper, Cdouble,
                         (Cint, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Void}))

module Step

using Parameters
using POLO: AbstractStep, AbstractPolicyParameters
import POLO: initialize!, stepsize

function initialize!(policy::AbstractStep,x₀::Vector{Float64})
    nothing
end

include("constant.jl")
include("decreasing.jl")

end
