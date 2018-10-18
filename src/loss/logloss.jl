struct LogLoss{M,Value<:AbstractFloat} <: AbstractLoss
  A::M
  b::Vector{Value}

  function (::Type{LogLoss})(A::AbstractMatrix, b::AbstractVector)
    @assert size(A, 1) == length(b) "`A` and `b` must have compatible dimensions"
    Value = float(promote_type(eltype(A), eltype(b)))
    mat = convert(AbstractMatrix{Value}, A)

    new{typeof(mat), Value}(mat, Vector{Value}(b))
  end
end

nsamples(loss::LogLoss)   = size(loss.A, 1)
nfeatures(loss::LogLoss)  = size(loss.A, 2)

function _value(x::AbstractVector{<:Real}, A::AbstractMatrix, b::AbstractVector)
  temp = exp.(-b .* (A*x))
  for idx in 1:length(temp)
    @inbounds temp[idx] = isinf(temp[idx]) ? -b[idx]*dot(A[idx,:], x) : log1p(temp[idx])
  end
  return sum(temp)
end

value(loss::LogLoss, x::AbstractVector{<:Real}) = _value(x, loss.A, loss.b)

function value(loss::LogLoss, x::AbstractVector{<:Real},
               comps::AbstractVector{<:Integer})
  N, d = nsamples(loss), nfeatures(loss)
  compmin, compmax = extrema(comps)
  A, b = loss.A[comps,:], loss.b[comps]
  return _value(x, A, b)
end

function _gradient!(x::AbstractVector{T}, dx::AbstractVector{T},
                    A::AbstractMatrix, b::AbstractVector) where {T <: Real}
  temp = exp.(-b .* (A*x))
  for idx in 1:length(temp)
    @inbounds temp[idx] = isinf(temp[idx]) ? -b[idx] : -b[idx]*temp[idx]/(one(T) + temp[idx])
  end
  return mul!(dx, transpose(A), temp)
end

function gradient!(loss::LogLoss, x::AbstractVector{T},
                   dx::AbstractVector{T}) where {T<:Real}
  A, b = loss.A, loss.b
  return _gradient!(x, dx, A, b)
end

function gradient!(loss::LogLoss, x::AbstractVector{T}, dx::AbstractVector{T},
                   comps::AbstractVector{<:Integer}) where {T<:Real}
  N, d = nsamples(loss), nfeatures(loss)
  compmin, compmax = extrema(comps)
  A, b = loss.A[comps,:], loss.b[comps]
  return _gradient!(x, dx, A, b)
end

# TODO: Still not efficient. Make a helper function to avoid calling `temp =
# exp.(-b .* (A*x)) twice, i.e., one for `gradient!` and another for `value`.
function loss!(loss::LogLoss, x::AbstractVector, g::AbstractVector)
  gradient!(loss,x,g)
  return value(loss,x)
end
