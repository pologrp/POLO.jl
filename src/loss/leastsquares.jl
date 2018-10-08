mutable struct LeastSquares{T} <: AbstractLoss
    A::Matrix{T}
    b::Vector{T}
    temp::Vector{T}

    function (::Type{LeastSquares})(A::Matrix, b::Vector)
        T = promote_type(eltype(Q), eltype(b))
        new{T}(A, b)
    end

    function (::Type{LeastSquares})(N::Integer, d::Integer)
        @assert d ≥ 1 "d must be at least 1"
        @assert N ≥ d "N must be at least $(d)"

        A = randn(N, d)
        A *= 2/norm(A)
        b = Float64[rand() ≤ 0.5 ? -1. : 1. for idx in 1:N]
        T = promote_type(eltype(A), eltype(b))
        new{T}(A, b, copy(b))
    end
end

nfeatures(loss::LeastSquares) = size(loss.A,2)
nsamples(loss::LeastSquares) = size(loss.A,1)

function loss!(loss::LeastSquares{T}, x::Vector{T}, g::Vector{T}) where T
    mul!(loss.temp,loss.A,x)
    result = convert(T, 0.5) * norm(loss.temp-loss.b,2)^2
    mul!(g, adjoint(loss.A), loss.temp)
    return result
end
