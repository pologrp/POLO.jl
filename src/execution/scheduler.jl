const proxgradient_scheduler = Libdl.dlsym(mylib, :proxgradient_scheduler)
const delete_proxgradient_scheduler = Libdl.dlsym(mylib, :delete_proxgradient_scheduler)
const run_scheduler = Libdl.dlsym(mylib, :run_scheduler)
# const getf_scheduler = Libdl.dlsym(mylib, :getf_scheduler)
# const getx_scheduler = Libdl.dlsym(mylib, :getx_scheduler)

mutable struct Scheduler <: ParameterServer
    popts::Ptr{Void}
    paramoptions::ParameterServerOptions

    function (::Type{Scheduler})(; kw...)
        scheduler =  new(C_NULL,ParameterServerOptions(; kw...))
        initialize_paramserver_options!(scheduler)
    end
end
Base.cconvert(::Type{Ptr{Void}}, scheduler::Scheduler)       = scheduler
Base.unsafe_convert(::Type{Ptr{Void}}, scheduler::Scheduler) = scheduler.popts
function destruct(scheduler::Scheduler)
    ccall(delete_paramserver_options, Void, (Ptr{Void},), scheduler)
end

paramserver_handle(::Scheduler) = proxgradient_scheduler
execution_handle(::Scheduler) = run_scheduler
delete_handle(::Scheduler) = delete_proxgradient_scheduler
# getf_handle(::Scheduler) = getf_scheduler
# getx_handle(::Scheduler) = getx_scheduler
