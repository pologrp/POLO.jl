struct LogLoss <: AbstractLoss
  N::Int
  d::Int
  A::Matrix{Float64}
  b::Vector{Float64}

  function (::Type{LogLoss})(N::Integer, d::Integer)
    @assert d ≥ 1 "d must be at least 1"
    @assert N ≥ d "N must be at least $(d)"

    A = randn(N, d)
    A *= 2/norm(A)
    b = Float64[rand() ≤ 0.5 ? -1. : 1. for idx in 1:N]

    new(N, d, A, b)
  end
end

nfeatures(loss::LogLoss)    = loss.d
nsamples(loss::LogLoss)   = loss.N

function _value{T<:Real}(x::AbstractVector{T}, A::AbstractMatrix,
  b::AbstractVector, N::Integer)
  temp = exp.(-b .* (A*x))
  for idx in 1:length(temp)
    @inbounds temp[idx] = isinf(temp[idx]) ? -b[idx]*dot(A[idx,:], x) :
                                            log1p(temp[idx])
  end
  return sum(temp)/N
end

function value{T<:Real}(loss::LogLoss, x::AbstractVector{T})
  N, d, A, b = loss.N, loss.d, loss.A, loss.b
  if length(x) ≠ nfeatures(loss)
    warn("value: `x` must have a length of `nfeatures(loss)`")
    throw(DomainError())
  end
  return _value(x, A, b, N)
end

function value{T<:Real,S<:Integer}(loss::LogLoss, x::AbstractVector{T},
  comps::AbstractVector{S})
  N, d = loss.N, loss.d
  compmin, compmax = extrema(comps)
  if length(x) ≠ nfeatures(loss)
    warn("value: `x` must have a length of `nfeatures(loss)`")
    throw(DomainError())
  elseif compmin < 1 || compmax > N
    warn("value: `comps` must lie within [1,$(N)]")
    throw(DomainError())
  end
  A, b = loss.A[comps,:], loss.b[comps]
  return _value(x, A, b, N)
end

function _gradient!{T<:Real}(x::AbstractVector{T}, dx::AbstractVector{T},
  A::AbstractMatrix, b::AbstractVector, N::Integer)
  temp = exp.(-b .* (A*x))

  for idx in 1:length(temp)
    @inbounds temp[idx] = isinf(temp[idx]) ? -b[idx]/N :
                                             -b[idx]*temp[idx]/(1. + temp[idx])/N
  end

  return At_mul_B!(dx, A, temp)
end

function gradient!{T<:Real}(loss::LogLoss, x::AbstractVector{T},
  dx::AbstractVector{T})
  N, d, A, b = loss.N, loss.d, loss.A, loss.b
  if length(x) ≠ length(dx) || length(x) ≠ nfeatures(loss)
    warn("gradient!: Both `x` and `dx` must have a length of `nfeatures(loss)`")
    throw(DomainError())
  end

  return _gradient!(x, dx, A, b, N)
end

function gradient!{T<:Real,S<:Integer}(loss::LogLoss, x::AbstractVector{T},
  dx::AbstractVector{T}, comps::AbstractVector{S})
  N, d = loss.N, loss.d
  compmin, compmax = extrema(comps)
  if length(x) ≠ length(dx) || length(x) ≠ nfeatures(loss)
    warn("gradient!: Both `x` and `dx` must have a length of `nfeatures(loss)`")
    throw(DomainError())
  elseif compmin < 1 || compmax > N
    warn("gradient!: `comps` must lie within [1,$(N)]")
    throw(DomainError())
  end
  A, b = loss.A[comps,:], loss.b[comps]
  return _gradient!(x, dx, A, b, N)
end

function loss!(loss::LogLoss, x::AbstractVector, g::AbstractVector)
    gradient!(loss,x,g)
    return value(loss,x)
end
