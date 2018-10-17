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

function initialize!(proxgrad::ProxGradient{<:ParameterServer})
    init_c = @cfunction(init_wrapper, Nothing,
                        (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cvoid}))
    boost = POLO.boosting(proxgrad)
    boosting_c = @cfunction(boost_wrapper, Ptr{Cdouble},
                              (Cint, Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cvoid}))
    step = POLO.stepsize(proxgrad)
    step_c = @cfunction(step_wrapper, Cdouble,
                          (Cint, Cint, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cvoid}))
    smooth = POLO.smoothing(proxgrad)
    smoothing_c = @cfunction(smooth_wrapper, Ptr{Cdouble},
                               (Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cvoid}))
    proxim = POLO.prox(proxgrad)
    prox_c = @cfunction(prox_wrapper, Ptr{Cdouble},
                          (Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cvoid}))
    proxgrad.ptr =  ccall(paramserver_handle(proxgrad.execution), Ptr{Nothing},
                          (Ptr{Nothing},
                           Ptr{Nothing}, Any,
                           Ptr{Nothing}, Any,
                           Ptr{Nothing}, Any,
                           Ptr{Nothing}, Any,
                           Any),
                          init_c,
                          boosting_c, boost,
                          step_c, step,
                          smoothing_c, smooth,
                          prox_c, proxim,
                          proxgrad.execution.popts)
    return proxgrad
end

function initialize_paramserver_options!(paramserver::ParameterServer)
    paramserver.popts = ccall(POLO.paramserver_options, Ptr{Nothing}, ())
    ccall(POLO.linger, Nothing, (Ptr{Nothing},Cint), paramserver.popts, paramserver.paramoptions.linger)
    ccall(POLO.master_timeout, Nothing, (Ptr{Nothing},Clong), paramserver.popts, paramserver.paramoptions.master_timeout)
    ccall(POLO.worker_timeout, Nothing, (Ptr{Nothing},Clong), paramserver.popts, paramserver.paramoptions.worker_timeout)
    ccall(POLO.scheduler_timeout, Nothing, (Ptr{Nothing},Clong), paramserver.popts, paramserver.paramoptions.scheduler_timeout)
    ccall(POLO.num_masters, Nothing, (Ptr{Nothing},Int32), paramserver.popts, paramserver.paramoptions.num_masters)
    pub_port, master_port, worker_port = paramserver.paramoptions.scheduler_ports
    ccall(POLO.scheduler, Nothing,
          (Ptr{Nothing},Ptr{UInt8},
           Cushort,Cushort,
           Cushort),
          paramserver.popts,
          paramserver.paramoptions.scheduler_address,
          pub_port,
          master_port,
          worker_port)
    ccall(POLO.master, Nothing,
          (Ptr{Nothing},Ptr{UInt8},Cushort),
          paramserver.popts,
          paramserver.paramoptions.master_address,
          paramserver.paramoptions.master_port)
    return paramserver
end

include("master.jl")
include("worker.jl")
include("scheduler.jl")
