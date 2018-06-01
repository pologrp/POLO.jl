abstract type AbstractPolicy end
abstract type AbstractPolicyParameters end

function initialize!(policy::AbstractPolicy,x₀::Vector{Float64})
    nothing
end

params(policy::AbstractPolicy) = nothing

function init_cwrapper(policy::P) where P <: AbstractPolicy
    init = (xbegin::Ptr{Cdouble},xend::Ptr{Cdouble},policy_data::Ptr{Void}) -> begin
        policy = unsafe_pointer_to_objref(policy_data)::P
        ptrdiff = Int(xend - xbegin)
        N = divrem(ptrdiff, sizeof(Cdouble))[1]
        x₀ = unsafe_wrap(Array, xbegin, N)
        method_exists(initialize!,(P,Vector{Float64})) || error("No initialize! function for policy ",P)
        initialize!(policy, x₀)
        nothing
    end
    init_c = cfunction(init, Void,
                       (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Void}))
    return init_c
end
