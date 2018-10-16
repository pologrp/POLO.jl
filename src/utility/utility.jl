abstract type AbstractLogger end
abstract type AbstractTermination end

function terminate(::AbstractTermination,k::Integer,fval::AbstractFloat,x::AbstractVector,g::AbstractVector) end

function termination_wrapper(k::Cint,fval::Cdouble,xbegin::Ptr{Cdouble},
                             xend::Ptr{Cdouble}, gbegin::Ptr{Cdouble},
                             termination_data::Ptr{Nothing})
    termination = unsafe_pointer_to_objref(termination_data)::AbstractTermination
    ptrdiff = Int(xend - xbegin)
    N = divrem(ptrdiff, sizeof(Cdouble))[1]
    x = unsafe_wrap(Array, xbegin, N)
    g = unsafe_wrap(Array, gbegin, N)
    return Cint(terminate(termination,k,fval,x,g))
end

function log(::AbstractLogger,k::Integer,fval::AbstractFloat,x::AbstractVector,g::AbstractVector) end

function log_wrapper(k::Cint,fval::Cdouble,xbegin::Ptr{Cdouble},
                     xend::Ptr{Cdouble}, gbegin::Ptr{Cdouble},
                     logger_data::Ptr{Nothing})
    logger = unsafe_pointer_to_objref(logger_data)::AbstractLogger
    ptrdiff = Int(xend - xbegin)
    N = divrem(ptrdiff, sizeof(Cdouble))[1]
    x = unsafe_wrap(Array, xbegin, N)
    g = unsafe_wrap(Array, gbegin, N)
    log(logger,k,fval,x,g)
    return nothing
end

module Utility

using POLO
using POLO: AbstractTermination, AbstractLogger
using LinearAlgebra
using SparseArrays

import POLO: terminate

include("termination.jl")
include("logging.jl")

# TODO:
# 1. Maybe we can redesign `reader`s as above, i.e., `AbstractReader`.
# 2. Implement `svmreader` to support "dense" reading --- that will be more
#    efficient compared to the `push!`s.
# 3. One can still make improvements when `m` and `n` are known.
# 4. Add tests.
include("svmreader.jl")

end
