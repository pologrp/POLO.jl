const mylib = Libdl.dlopen(joinpath(dirname(@__FILE__), "../..", "install", "lib", "libapi.so"));
const paramserver_options = Libdl.dlsym(mylib, :paramserver_options)
const delete_paramserver_options = Libdl.dlsym(mylib, :delete_paramserver_options)
const linger = Libdl.dlsym(mylib, :linger)
const master_timeout = Libdl.dlsym(mylib, :master_timeout)
const worker_timeout = Libdl.dlsym(mylib, :worker_timeout)
const scheduler_timeout = Libdl.dlsym(mylib, :scheduler_timeout)
const num_masters = Libdl.dlsym(mylib, :num_masters)
const scheduler = Libdl.dlsym(mylib, :scheduler)
const master = Libdl.dlsym(mylib, :master)

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
    proxgrad.ptr =  ccall(paramserver_handle(proxgrad.execution), Ptr{Void},
                          (Ptr{Void},
                           Ptr{Void}, Any,
                           Ptr{Void}, Any,
                           Ptr{Void}, Any,
                           Ptr{Void}, Any,
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
    paramserver.popts = ccall(paramserver_options, Ptr{Void}, ())
    ccall(linger, Void, (Ptr{Void},Cint), paramserver.popts, paramserver.paramoptions.linger)
    ccall(master_timeout, Void, (Ptr{Void},Clong), paramserver.popts, paramserver.paramoptions.master_timeout)
    ccall(worker_timeout, Void, (Ptr{Void},Clong), paramserver.popts, paramserver.paramoptions.worker_timeout)
    ccall(scheduler_timeout, Void, (Ptr{Void},Clong), paramserver.popts, paramserver.paramoptions.scheduler_timeout)
    ccall(num_masters, Void, (Ptr{Void},Cint), paramserver.popts, paramserver.paramoptions.num_masters)
    pub_port, master_port, worker_port = paramserver.paramoptions.scheduler_ports
    ccall(scheduler, Void,
          (Ptr{Void},Ptr{UInt8},
           Cushort,Cushort,
           Cushort),
          paramserver.popts,
          paramserver.paramoptions.scheduler_address,
          pub_port,
          master_port,
          worker_port)
    ccall(master, Void,
          (Ptr{Void},Ptr{UInt8},Cushort),
          paramserver.popts,
          paramserver.paramoptions.master_address,
          paramserver.paramoptions.master_port)
    return paramserver
end

include("master.jl")
include("worker.jl")
include("scheduler.jl")
