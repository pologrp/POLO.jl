struct None <: AbstractSmoothing end

function smooth!(::None,klocal::Integer,kglobal::Integer,x::AbstractVector,gprev::AbstractVector,gcurr::AbstractVector)
    gcurr .= gprev
end
