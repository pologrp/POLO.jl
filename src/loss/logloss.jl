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

function loss!(loss::LogLoss, x::AbstractVector, g::AbstractVector)
  T = eltype(x)
  val = -loss.b .* (loss.A * x)
  fval = zero(T)

  for idx in 1:length(val)
    temp = exp(val[idx])
    @inbounds fval += isinf(temp) ? val[idx] : log1p(temp)
    @inbounds val[idx] = isinf(temp) ? -b[idx] : -b[idx]*temp/(one(T) + temp)
  end
  mul!(g, transpose(A), temp)
  return fval
end
