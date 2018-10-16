# const getf_scheduler = Libdl.dlsym(polo_lib, :getf_scheduler)
# const getx_scheduler = Libdl.dlsym(polo_lib, :getx_scheduler)

mutable struct Scheduler <: ParameterServer
    popts::Ptr{Cvoid}
    paramoptions::ParameterServerOptions

    function (::Type{Scheduler})(; kw...)
        scheduler =  new(C_NULL,ParameterServerOptions(; kw...))
        initialize_paramserver_options!(scheduler)
    end
end
Base.cconvert(::Type{Ptr{Cvoid}}, scheduler::Scheduler)       = scheduler
Base.unsafe_convert(::Type{Ptr{Cvoid}}, scheduler::Scheduler) = scheduler.popts
function destruct(scheduler::Scheduler)
    ccall(delete_paramserver_options, Nothing, (Ptr{Cvoid},), scheduler)
end

paramserver_handle(::Scheduler) = POLO.proxgradient_scheduler
execution_handle(::Scheduler) = POLO.run_scheduler
delete_handle(::Scheduler) = POLO.delete_proxgradient_scheduler
# getf_handle(::Scheduler) = getf_scheduler
# getx_handle(::Scheduler) = getx_scheduler
