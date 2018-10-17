# const getf_master = Libdl.dlsym(polo_lib, :getf_master)
# const getx_master = Libdl.dlsym(polo_lib, :getx_master)

struct Master <: ParameterServer
    fval::Float64
    x::Vector{Float64}
    psopts::ParameterServerOptions

    function (::Type{Master})(; kw...)
        master =  new(0., Vector{Float64}(), ParameterServerOptions(; kw...))
    end
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
