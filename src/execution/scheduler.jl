# const getf_scheduler = Libdl.dlsym(polo_lib, :getf_scheduler)
# const getx_scheduler = Libdl.dlsym(polo_lib, :getx_scheduler)

struct Scheduler <: ParameterServer
    fval::Float64
    x::Vector{Float64}
    psopts::ParameterServerOptions

    function (::Type{Scheduler})(; kw...)
        scheduler =  new(0., Vector{Float64}(), ParameterServerOptions(; kw...))
    end
end

function initialize!(scheduler::Scheduler, x₀::AbstractVector)
    resize!(scheduler.x,length(x₀))
    scheduler.x .= x₀
end
getx(scheduler::Scheduler) = scheduler.x

function (proxgrad::ProxGradient{Scheduler})(x₀::AbstractVector,termination::AbstractTermination,logger::AbstractLogger)
    initialize!(proxgrad.execution, x₀)
    xbegin = pointer(x₀, 1)
    xend = pointer(x₀, length(x₀) + 1)
    termination_c = @cfunction(POLO.termination_wrapper, Cint,
                               (Cint, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Nothing}))
    log_c = @cfunction(POLO.log_wrapper, Nothing,
                       (Cint, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Nothing}))
    return ccall(POLO.run_scheduler, Nothing,
                 (Ptr{Nothing},Ptr{Cdouble}, Ptr{Cdouble},
                  Ptr{Nothing}, Any,
                  Ptr{Nothing}, Any),
                 proxgrad,
                 xbegin, xend,
                 termination_c, termination,
                 log_c, logger)
end
function (proxgrad::ProxGradient{Scheduler})(x₀::AbstractVector)
    termination = POLO.Utility.MaxIteration(100)
    return proxgrad(x₀,termination,POLO.Utility.ProgressLogger.Value(termination))
end

paramserver_handle(::Scheduler) = POLO.proxgradient_scheduler
execution_handle(::Scheduler) = POLO.run_scheduler
delete_handle(::Scheduler) = POLO.delete_proxgradient_scheduler
# getf_handle(::Scheduler) = getf_scheduler
# getx_handle(::Scheduler) = getx_scheduler
