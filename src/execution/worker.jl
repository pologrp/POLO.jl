# const getf_worker = Libdl.dlsym(polo_lib, :getf_worker)
# const getx_worker = Libdl.dlsym(polo_lib, :getx_worker)

mutable struct Worker <: ParameterServer
    popts::Ptr{Cvoid}
    paramoptions::ParameterServerOptions

    function (::Type{Worker})(; kw...)
        worker =  new(C_NULL,ParameterServerOptions(; kw...))
        initialize_paramserver_options!(worker)
    end
end
Base.cconvert(::Type{Ptr{Cvoid}}, worker::Worker)       = worker
Base.unsafe_convert(::Type{Ptr{Cvoid}}, worker::Worker) = worker.popts
function destruct(worker::Worker)
    ccall(delete_paramserver_options, Nothing, (Ptr{Cvoid},), worker)
end

paramserver_handle(::Worker) = POLO.proxgradient_worker
execution_handle(::Worker) = POLO.run_worker
delete_handle(::Worker) = POLO.delete_proxgradient_worker
# getf_handle(::Worker) = getf_worker
# getx_handle(::Worker) = getx_worker
