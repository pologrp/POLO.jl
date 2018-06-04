abstract type AbstractPolicy end
abstract type AbstractPolicyParameters end

# function initialize!(policy::AbstractPolicy,x₀::Vector{Float64})
#     error("No initialize! function for policy ", typeof(policy))
# end

function initialize!() end

params(policy::AbstractPolicy) = nothing

function init_wrapper(xbegin::Ptr{Cdouble},xend::Ptr{Cdouble},policy_data::Ptr{Void})::Void
    policy = unsafe_pointer_to_objref(policy_data)::AbstractPolicy
    ptrdiff = Int(xend - xbegin)
    N = divrem(ptrdiff, sizeof(Cdouble))[1]
    x₀ = unsafe_wrap(Array, xbegin, N)
    initialize!(policy, x₀)
    nothing
end

const init_c = cfunction(init_wrapper, Void,
                         (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Void}))
