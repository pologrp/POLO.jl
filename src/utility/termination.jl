struct MaxIteration <: AbstractTermination
    K::Int

    function (::Type{MaxIteration})(K::Int)
        return new(K)
    end
end

function terminate(maxiter::MaxIteration,k::Integer,fval::AbstractFloat,x::AbstractVector,g::AbstractVector)
    return k > maxiter.K
end

struct GradientNorm <: AbstractTermination
    ϵ::Float64

    function (::Type{GradientNorm})(ϵ::Float64)
        return new(ϵ)
    end
end

function terminate(gradnorm::GradientNorm,k::Integer,fval::AbstractFloat,x::AbstractVector,g::AbstractVector)
    return k > 1 && norm(g) <= gradnorm.ϵ
end
