struct None <: AbstractBoosting end

function boost!(::None,gprev::AbstractVector,gcurr::AbstractVector)
    gcurr .= gprev
end
