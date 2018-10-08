# const getf_master = Libdl.dlsym(polo_lib, :getf_master)
# const getx_master = Libdl.dlsym(polo_lib, :getx_master)

mutable struct Master <: ParameterServer
    popts::Ptr{Cvoid}
    paramoptions::ParameterServerOptions

    function (::Type{Master})(; kw...)
        master =  new(C_NULL,ParameterServerOptions(; kw...))
        initialize_paramserver_options!(master)
    end
end
Base.cconvert(::Type{Ptr{Cvoid}}, master::Master)       = master
Base.unsafe_convert(::Type{Ptr{Cvoid}}, master::Master) = master.popts
function destruct(master::Master)
    ccall(delete_paramserver_options, Nothing, (Ptr{Cvoid},), master)
end

paramserver_handle(::Master) = proxgradient_master
execution_handle(::Master) = run_master
delete_handle(::Master) = delete_proxgradient_master
# getf_handle(::Master) = getf_master
# getx_handle(::Master) = getx_master
