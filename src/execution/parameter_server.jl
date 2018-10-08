@with_kw mutable struct ParameterServerOptions
    linger::Int32 = Int32(1000)
    master_timeout::Int = 10000
    worker_timeout::Int = -1
    scheduler_timeout::Int = -1
    num_masters::Int32 = Int32(1)
    scheduler_address::String = "localhost"
    master_address::String = ""
    scheduler_ports::Tuple{UInt16,UInt16,UInt16} = (UInt16(40000),UInt16(40001),UInt16(40002))
    master_port::UInt16 = UInt16(40001)
end

abstract type ParameterServer <: ExecutionPolicy end
paramserver_handle(::ParameterServer) = C_NULL

function initialize!(proxgrad::ProxGradient{ParameterServer})
    boost = POLO.boosting(proxgrad)
    step = POLO.stepsize(proxgrad)
    smooth = POLO.smoothing(proxgrad)
    proxim = POLO.prox(proxgrad)
    param_options = proxgrad.execution.popts
    proxgrad.ptr =  ccall(paramserver_handle(proxgrad.execution), Ptr{Nothing},
                          (Ptr{Nothing},
                           Ptr{Nothing}, Any,
                           Ptr{Nothing}, Any,
                           Ptr{Nothing}, Any,
                           Ptr{Nothing}, Any,
                           Any),
                          POLO.init_c,
                          POLO.boosting_c, boost,
                          POLO.step_c, step,
                          POLO.smoothing_c, smooth,
                          POLO.prox_c, proxim,
                          param_options)
    return proxgrad
end

function initialize_paramserver_options!(paramserver::ParameterServer)
    paramserver.popts = ccall(paramserver_options, Ptr{Nothing}, ())
    ccall(linger, Nothing, (Ptr{Nothing},Cint), paramserver.popts, paramserver.paramoptions.linger)
    ccall(master_timeout, Nothing, (Ptr{Nothing},Clong), paramserver.popts, paramserver.paramoptions.master_timeout)
    ccall(worker_timeout, Nothing, (Ptr{Nothing},Clong), paramserver.popts, paramserver.paramoptions.worker_timeout)
    ccall(scheduler_timeout, Nothing, (Ptr{Nothing},Clong), paramserver.popts, paramserver.paramoptions.scheduler_timeout)
    ccall(num_masters, Nothing, (Ptr{Nothing},Cint), paramserver.popts, paramserver.paramoptions.num_masters)
    pub_port, master_port, worker_port = paramserver.paramoptions.scheduler_ports
    ccall(scheduler, Nothing,
          (Ptr{Nothing},Ptr{UInt8},
           Cushort,Cushort,
           Cushort),
          paramserver.popts,
          paramserver.paramoptions.scheduler_address,
          pub_port,
          master_port,
          worker_port)
    ccall(master, Nothing,
          (Ptr{Nothing},Ptr{UInt8},Cushort),
          paramserver.popts,
          paramserver.paramoptions.master_address,
          paramserver.paramoptions.master_port)
    return paramserver
end

include("master.jl")
include("worker.jl")
include("scheduler.jl")
