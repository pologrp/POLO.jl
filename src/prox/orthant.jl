abstract type OrthantTrait end
abstract type Positive <: OrthantTrait end
abstract type Negative <: OrthantTrait end

struct Orthant{T <: OrthantTrait} <: AbstractProx
    function (::Type{Orthant})(::Type{T}) where T <: OrthantTrait
        return new{T}()
    end
end

function prox!(orthant::Orthant{Positive},step::Real,xprev::AbstractVector,gcurr::AbstractVector,xcurr::AbstractVector)
    xcurr .= max.(xprev-step*gcurr, zeros(xprev))
end

function prox!(orthant::Orthant{Negative},step::Real,xprev::AbstractVector,gcurr::AbstractVector,xcurr::AbstractVector)
    xcurr .= min.(xprev-step*gcurr, zeros(xprev))
end

PositiveOrthant() = Orthant(Positive)
NegativeOrthant() = Orthant(Negative)
