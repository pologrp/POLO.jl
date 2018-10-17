# const getf_worker = Libdl.dlsym(polo_lib, :getf_worker)
# const getx_worker = Libdl.dlsym(polo_lib, :getx_worker)

struct Worker <: ParameterServer
    fval::Float64
    x::Vector{Float64}
    psopts::ParameterServerOptions

    function (::Type{Worker})(; kw...)
        worker =  new(0., Vector{Float64}(), ParameterServerOptions(; kw...))
    end
end

function initialize!(worker::Worker, x₀::AbstractVector)
    resize!(worker.x,length(x₀))
    worker.x .= x₀
end
getx(worker::Worker) = worker.x

paramserver_handle(::Worker) = POLO.proxgradient_worker
execution_handle(::Worker) = POLO.run_worker
delete_handle(::Worker) = POLO.delete_proxgradient_worker
# getf_handle(::Worker) = getf_worker
# getx_handle(::Worker) = getx_worker
