module Dummy
const mylib = Libdl.dlopen(joinpath(pwd(), "../install", "lib", "libapi.so"));
const test = Libdl.dlsym(mylib, :test)

abstract type AbstractLoss end

function loss!(loss::AbstractLoss, x::AbstractVector, g::AbstractVector)
    error("No defined loss! function for loss function ", typeof(loss))
end

struct LeastSquares{T} <: AbstractLoss
  Q::Matrix{T}
  q::Vector{T}

  function (::Type{LeastSquares})(Q::Matrix, q::Vector)
    T = promote_type(eltype(Q), eltype(q))
    new{T}(Q, q)
  end
end

nfeatures(loss::LeastSquares) = size(loss.Q,2)

function loss!(loss::LeastSquares{T}, x::Vector{T}, g::Vector{T}) where T
  temp = loss.Q * x
  result = convert(T, 0.5) * dot(temp, x) + dot(loss.q, x)
  g .= temp + loss.q
  return result
end

function loss_wrapper(xbegin::Ptr{Cdouble},gbegin::Ptr{Cdouble},loss_data::Ptr{Void})
    loss = unsafe_pointer_to_objref(loss_data)::AbstractLoss
    N = nfeatures(loss)
    x = unsafe_wrap(Array, xbegin, N)
    g = unsafe_wrap(Array, gbegin, N)
    val = loss!(loss, x, g)
    return val
end

const loss_c = cfunction(loss_wrapper, Cdouble,
                         (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Void}))

function testit(x₀::AbstractVector,loss::AbstractLoss)
    g = zeros(x₀)
    return ccall(test, Cdouble,
          (Ptr{Cdouble}, Ptr{Cdouble},
           Ptr{Void}, Any),
          x₀, g, loss_c, loss)
end

export testit

end

using Dummy
testit(randn(2),Dummy.LeastSquares(eye(2),[1,2]))
