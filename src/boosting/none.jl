struct None <: AbstractBoosting end

function boost!(::None,wid::Integer,klocal::Integer,kglobal::Integer,gprev::AbstractVector,gcurr::AbstractVector)
    gcurr .= gprev
end
