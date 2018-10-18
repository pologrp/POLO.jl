struct LogLoss{M<:AbstractMatrix,V<:AbstractVector} <: AbstractLoss
  A::M
  b::V

  function (::Type{LogLoss})(A::AbstractMatrix, b::AbstractVector)
    @assert size(A, 1) == length(b) "`A` and `b` must have compatible dimensions"
    T = float(promote_type(eltype(A), eltype(b)))
    A_ = convert(AbstractMatrix{T}, A)
    b_ = convert(AbstractVector{T}, b)

    new{typeof(A_),typeof(b_)}(A_, b_)
  end
end

nsamples(loss::LogLoss)   = size(loss.A, 1)
nfeatures(loss::LogLoss)  = size(loss.A, 2)

function loss!(loss::LogLoss, x::AbstractVector{T}, g::AbstractVector{T}) where T
  val = -loss.b .* (loss.A * x)
  fval = zero(T)

  for idx in 1:length(val)
    temp = exp(val[idx])
    @inbounds fval += isinf(temp) ? val[idx] : log1p(temp)
    @inbounds val[idx] = isinf(temp) ? -loss.b[idx] : -loss.b[idx]*temp/(one(T) + temp)
  end
  mul!(g, transpose(loss.A), val)
  return fval
end
