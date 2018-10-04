const proxgradient_worker = Libdl.dlsym(mylib, :proxgradient_worker)
const delete_proxgradient_worker = Libdl.dlsym(mylib, :delete_proxgradient_worker)
const run_worker = Libdl.dlsym(mylib, :run_worker)
# const getf_worker = Libdl.dlsym(mylib, :getf_worker)
# const getx_worker = Libdl.dlsym(mylib, :getx_worker)

mutable struct Worker <: ParameterServer
    popts::Ptr{Void}
    paramoptions::ParameterServerOptions

    function (::Type{Worker})(; kw...)
        worker =  new(C_NULL,ParameterServerOptions(; kw...))
        initialize_paramserver_options!(worker)
    end
end
Base.cconvert(::Type{Ptr{Void}}, worker::Worker)       = worker
Base.unsafe_convert(::Type{Ptr{Void}}, worker::Worker) = worker.popts
function destruct(worker::Worker)
    ccall(delete_paramserver_options, Void, (Ptr{Void},), worker)
end

paramserver_handle(::Worker) = proxgradient_worker
execution_handle(::Worker) = run_worker
delete_handle(::Worker) = delete_proxgradient_worker
# getf_handle(::Worker) = getf_worker
# getx_handle(::Worker) = getx_worker
