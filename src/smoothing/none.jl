struct None <: AbstractSmoothing end

function smooth!(::None,x::AbstractVector,gprev::AbstractVector,gcurr::AbstractVector)
    gcurr = gprev
end
