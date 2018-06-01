abstract type AbstractLoss end

function loss_cwrapper(loss::L) where L <: AbstractLoss
    return (xbegin::Ptr{Cdouble},xend::Ptr{Cdouble},gbegin::Ptr{Cdouble},loss_data::Ptr{Void}) -> begin
        loss = unsafe_pointer_to_objref(loss_data)::Loss
        ptrdiff = Int(xend - xbegin)
        N = divrem(ptrdiff, sizeof(Cdouble))[1]
        x = unsafe_wrap(Array, xbegin, N)
        g = unsafe_wrap(Array, gbegin, N)
        method_exists(loss!,(L,Vector{Float64},Vector{Float64})) || error("No defined loss! function for loss function ",L)
        return loss!(loss, x, g)
    end
end

module Loss

using Parameters
using POLO: AbstractStep, AbstractPolicyParameters

include("logloss.jl")

end
