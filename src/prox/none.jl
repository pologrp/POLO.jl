struct None <: AbstractProx end

function prox!(::None,step::Real,xprev::AbstractVector,gcurr::AbstractVector,xcurr::AbstractVector)
    xcurr .= xprev - step*gcurr
end
