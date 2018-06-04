abstract type AbstractLoss end

function loss!(loss::AbstractLoss, x::AbstractVector, g::AbstractVector)
    error("No defined loss! function for loss function ", typeof(loss))
end

function loss_wrapper(xbegin::Ptr{Cdouble},xend::Ptr{Cdouble},gbegin::Ptr{Cdouble},loss_data::Ptr{Void})::Cdouble
    loss = unsafe_pointer_to_objref(loss_data)::AbstractLoss
    ptrdiff = Int(xend - xbegin)
    N = divrem(ptrdiff, sizeof(Cdouble))[1]
    x = unsafe_wrap(Array, xbegin, N)
    g = unsafe_wrap(Array, gbegin, N)
    return loss!(loss, x, g)
end

const loss_c = cfunction(loss_wrapper, Cdouble,
                         (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Void}))

module Loss

using Parameters
using POLO: AbstractLoss

include("logloss.jl")

end
