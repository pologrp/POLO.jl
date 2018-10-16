abstract type AbstractLoss end

# function loss!(loss::AbstractLoss, x::AbstractVector, g::AbstractVector)
#     error("No defined loss! function for loss function ", typeof(loss))
# end

function loss!() end

function nfeatures() end

function loss_wrapper(xbegin::Ptr{Cdouble},gbegin::Ptr{Cdouble},loss_data::Ptr{Nothing})
    loss = unsafe_pointer_to_objref(loss_data)::AbstractLoss
    N = nfeatures(loss)
    x = unsafe_wrap(Array, xbegin, N)
    g = unsafe_wrap(Array, gbegin, N)
    val = loss!(loss, x, g)::Float64
    return val
end

module Loss

using LinearAlgebra
using SparseArrays
using DelimitedFiles
using POLO: AbstractLoss
import POLO: loss!, nfeatures

include("leastsquares.jl")
include("logloss.jl")

end
