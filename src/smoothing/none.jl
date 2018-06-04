struct None <: AbstractSmoothing end

function smooth!(::None,k::Integer,x::AbstractVector,gprev::AbstractVector,gcurr::AbstractVector)
    gcurr .= gprev
end
