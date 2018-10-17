# const getf_scheduler = Libdl.dlsym(polo_lib, :getf_scheduler)
# const getx_scheduler = Libdl.dlsym(polo_lib, :getx_scheduler)

mutable struct Scheduler <: ParameterServer
    fval::Float64
    x::Vector{Float64}
    popts::Ptr{Cvoid}
    paramoptions::ParameterServerOptions

    function (::Type{Scheduler})(; kw...)
        scheduler =  new(0., Vector{Float64}(), C_NULL, ParameterServerOptions(; kw...))
        initialize_paramserver_options!(scheduler)
    end
end
Base.cconvert(::Type{Ptr{Cvoid}}, scheduler::Scheduler)       = scheduler
Base.unsafe_convert(::Type{Ptr{Cvoid}}, scheduler::Scheduler) = scheduler.popts
function destruct(scheduler::Scheduler)
    ccall(delete_paramserver_options, Nothing, (Ptr{Cvoid},), scheduler)
end

function initialize!(scheduler::Scheduler, x₀::AbstractVector)
    resize!(scheduler.x,length(x₀))
    scheduler.x .= x₀
end
getx(scheduler::Scheduler) = scheduler.x

paramserver_handle(::Scheduler) = POLO.proxgradient_scheduler
execution_handle(::Scheduler) = POLO.run_scheduler
delete_handle(::Scheduler) = POLO.delete_proxgradient_scheduler
# getf_handle(::Scheduler) = getf_scheduler
# getx_handle(::Scheduler) = getx_scheduler
