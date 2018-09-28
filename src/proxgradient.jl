mutable struct ProxGradient{Execution <: ExecutionPolicy,
                            Boosting <: AbstractBoosting,
                            Step <: AbstractStep,
                            Smoothing <: AbstractSmoothing,
                            Prox <: AbstractProx}
    boosting::Boosting
    step::Step
    smoothing::Smoothing
    prox::Prox
    ptr::Ptr{Void}
    x::Vector{Float64}

    function (::Type{ProxGradient})(execution::Execution,
                                    boosting::Boosting,
                                    step::Step,
                                    smoothing::Smoothing,
                                    prox::Prox) where {Execution <: ExecutionPolicy,
                                                       Boosting <: AbstractBoosting,
                                                       Step <: AbstractStep,
                                                       Smoothing <: AbstractSmoothing,
                                                       Prox <: AbstractProx}
        proxgrad = new{Execution,Boosting,Step,Smoothing,Prox}(boosting,step,smoothing,prox)
        initialize!(proxgrad)
        return proxgrad
    end
end
Base.cconvert(::Type{Ptr{Void}}, proxgrad::ProxGradient)       = proxgrad
Base.unsafe_convert(::Type{Ptr{Void}}, proxgrad::ProxGradient) = proxgrad.ptr

function set_boosting_params!(proxgrad::ProxGradient; kwargs...)
    if params(proxgrad.boosting) == nothing
        return
    end
    for (k,v) in kwargs
        setfield!(params(proxgrad.boosting),k,v)
    end
end

function boosting(proxgrad::ProxGradient)
    return proxgrad.boosting
end

function set_step_params!(proxgrad::ProxGradient; kwargs...)
    if params(proxgrad.step) == nothing
        return
    end
    for (k,v) in kwargs
        setfield!(params(proxgrad.step),k,v)
    end
end

function stepsize(proxgrad::ProxGradient)
    return proxgrad.step
end

function set_smoothing_params!(proxgrad::ProxGradient; kwargs...)
    if params(proxgrad.smoothing) == nothing
        return
    end
    for (k,v) in kwargs
        setfield!(params(proxgrad.smoothing),k,v)
    end
end

function smoothing(proxgrad::ProxGradient)
    return proxgrad.smoothing
end

function set_prox_params!(proxgrad::ProxGradient; kwargs...)
    if params(proxgrad.prox) == nothing
        return
    end
    for (k,v) in kwargs
        setfield!(params(proxgrad.prox),k,v)
    end
end

function prox(proxgrad::ProxGradient)
    return proxgrad.prox
end
