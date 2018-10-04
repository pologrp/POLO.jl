const proxgradient_master = Libdl.dlsym(mylib, :proxgradient_master)
const delete_proxgradient_master = Libdl.dlsym(mylib, :delete_proxgradient_master)
const run_master = Libdl.dlsym(mylib, :run_master)
# const getf_master = Libdl.dlsym(mylib, :getf_master)
# const getx_master = Libdl.dlsym(mylib, :getx_master)

mutable struct Master <: ParameterServer
    popts::Ptr{Void}
    paramoptions::ParameterServerOptions

    function (::Type{Master})(; kw...)
        master =  new(C_NULL,ParameterServerOptions(; kw...))
        initialize_paramserver_options!(master)
    end
end
Base.cconvert(::Type{Ptr{Void}}, master::Master)       = master
Base.unsafe_convert(::Type{Ptr{Void}}, master::Master) = master.popts
function destruct(master::Master)
    ccall(delete_paramserver_options, Void, (Ptr{Void},), master)
end

paramserver_handle(::Master) = proxgradient_master
execution_handle(::Master) = run_master
delete_handle(::Master) = delete_proxgradient_master
# getf_handle(::Master) = getf_master
# getx_handle(::Master) = getx_master
