using LinearAlgebra

@with_kw mutable struct AffineParameters{T <: AbstractFloat} <: AbstractPolicyParameters
    A::Matrix{T}
    b::Vector{T}
end

mutable struct Affine <: AbstractProx
    params::AffineParameters{Float64}
    H::Cholesky{Float64,Matrix{Float64}}

    function (::Type{Affine})(; kwargs...)
        params = AffineParameters(; kwargs...)
        @unpack A = params
        return new(params,cholfact(A*A'))
    end
end

function prox!(affine::Affine,step::Real,xprev::AbstractVector,gcurr::AbstractVector,xcurr::AbstractVector)
    @unpack A,b = affine.params
    x = xprev - step*gcurr
    xcurr .= x + A'*(affine.H\(b-A*x))
end
