abstract type AbstractPolicy end
abstract type AbstractPolicyParameters end
abstract type ExecutionPolicy end

# function initialize!(policy::AbstractPolicy,x₀::Vector{Float64})
#     error("No initialize! function for policy ", typeof(policy))
# end

function initialize!() end

params(policy::AbstractPolicy) = nothing

function init_wrapper(xbegin::Ptr{Cdouble},xend::Ptr{Cdouble},policy_data::Ptr{Cvoid})::Nothing
    policy = unsafe_pointer_to_objref(policy_data)::AbstractPolicy
    ptrdiff = Int(xend - xbegin)
    N = divrem(ptrdiff, sizeof(Cdouble))[1]
    x₀ = unsafe_wrap(Array, xbegin, N)
    initialize!(policy, x₀)
    nothing
end
