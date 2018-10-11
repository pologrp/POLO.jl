mutable struct ProxGradient{Execution <: ExecutionPolicy,
                            Boosting <: AbstractBoosting,
                            Step <: AbstractStep,
                            Smoothing <: AbstractSmoothing,
                            Prox <: AbstractProx}
    execution::Execution
    boosting::Boosting
    step::Step
    smoothing::Smoothing
    prox::Prox
    ptr::Ptr{Nothing}
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
        proxgrad = new{Execution,Boosting,Step,Smoothing,Prox}(execution,boosting,step,smoothing,prox,C_NULL,zeros(0))
        initialize!(proxgrad)
        return proxgrad
    end
end
Base.cconvert(::Type{Ptr{Nothing}}, proxgrad::ProxGradient)       = proxgrad
Base.unsafe_convert(::Type{Ptr{Nothing}}, proxgrad::ProxGradient) = proxgrad.ptr
function destruct(proxgrad::ProxGradient)
    ccall(delete_handle(proxgrad.execution), Nothing, (Ptr{Nothing},), proxgrad)
end

function (proxgrad::ProxGradient)(x₀::AbstractVector,loss::AbstractLoss,termination::AbstractTermination,logger::AbstractLogger)
    resize!(proxgrad.x,length(x₀))
    proxgrad.x .= x₀
    xbegin = pointer(proxgrad.x, 1)
    xend = pointer(proxgrad.x, length(x₀) + 1)
    loss_c = @cfunction(loss_wrapper, Cdouble,
                        (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Nothing}))
    termination_c = @cfunction(termination_wrapper, Cint,
                               (Cint, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Nothing}))
    log_c = @cfunction(log_wrapper, Nothing,
                       (Cint, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Nothing}))
    return ccall(execution_handle(proxgrad.execution), Nothing,
                 (Ptr{Nothing},Ptr{Cdouble}, Ptr{Cdouble},
                  Ptr{Nothing}, Any,
                  Ptr{Nothing}, Any,
                  Ptr{Nothing}, Any),
                 proxgrad,
                 xbegin, xend,
                 loss_c, loss,
                 termination_c, termination,
                 log_c, logger)
end
function (proxgrad::ProxGradient)(x₀::AbstractVector,loss::AbstractLoss)
    termination = POLO.Utility.MaxIteration(100)
    return proxgrad(x₀,loss,termination,POLO.Utility.ProgressLogger.Value(termination))
end
function (proxgrad::ProxGradient)(x₀::AbstractVector,loss::AbstractLoss,termination::AbstractTermination)
    return proxgrad(x₀,loss,termination,POLO.Utility.ProgressLogger.Gradient(termination))
end

function getf(proxgrad::ProxGradient)
    return ccall(getf_handle(proxgrad.execution), Cdouble, (Ptr{Nothing},), proxgrad)
end

function getx!(proxgrad::ProxGradient)
    ccall(getx_handle(proxgrad.execution), Nothing, (Ptr{Nothing}, Ref{Cdouble}), proxgrad, proxgrad.x)
    return proxgrad.x
end

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
