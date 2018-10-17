mutable struct QP{T <: AbstractFloat} <: AbstractLoss
    Q::Matrix{T}
    q::Vector{T}
    temp::Vector{T}

    function (::Type{QP})(d::Integer, t::Real, ::Type{T} = Float64) where T
        Q = randn(T,d,d)
        q = randn(T,d)
        F = qr(Q)
        temp = t .^ rand(d-2)
        D = Diagonal(vcat(1/t,temp,t))
        mul!(Q, D, Matrix(F.Q))
        lmul!(F.Q', Q)

        return new{T}(Q, q, copy(q))
    end
end

nfeatures(loss::QP) = size(loss.Q,2)

function loss!(loss::QP{T}, x::Vector{T}, g::Vector{T}) where T <: AbstractFloat
    mul!(loss.temp,loss.Q,x)
    result = convert(T, 0.5) * x⋅loss.temp + loss.q⋅x
    g .= loss.temp .+ loss.q
    return result
end
