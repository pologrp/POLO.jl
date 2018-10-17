# const getf_master = Libdl.dlsym(polo_lib, :getf_master)
# const getx_master = Libdl.dlsym(polo_lib, :getx_master)

mutable struct Master <: ParameterServer
    fval::Float64
    x::Vector{Float64}
    popts::Ptr{Cvoid}
    paramoptions::ParameterServerOptions

    function (::Type{Master})(; kw...)
        master =  new(0., Vector{Float64}(), C_NULL,ParameterServerOptions(; kw...))
        initialize_paramserver_options!(master)
    end
end
Base.cconvert(::Type{Ptr{Cvoid}}, master::Master)       = master
Base.unsafe_convert(::Type{Ptr{Cvoid}}, master::Master) = master.popts
function destruct(master::Master)
    ccall(delete_paramserver_options, Nothing, (Ptr{Cvoid},), master)
end

function initialize!(master::Master, x₀::AbstractVector)
    resize!(master.x,length(x₀))
    master.x .= x₀
end
getx(master::Master) = master.x

paramserver_handle(::Master) = POLO.proxgradient_master
execution_handle(::Master) = POLO.run_master
delete_handle(::Master) = POLO.delete_proxgradient_master
# getf_handle(::Master) = getf_master
# getx_handle(::Master) = getx_master
