mutable struct LeastSquares{T} <: AbstractLoss
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
