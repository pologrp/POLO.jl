struct None <: AbstractBoosting end

function boost!(::None,gprev::AbstractVector,gcurr::AbstractVector)
    println("I am boosting")
    gcurr = gprev
end
