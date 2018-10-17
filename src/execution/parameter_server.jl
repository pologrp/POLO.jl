@with_kw struct ParameterServerOptions
    linger::Cint = Cint(1000)
    master_timeout::Clong = 10000
    worker_timeout::Clong = -1
    scheduler_timeout::Clong = -1
    num_masters::Int32 = Int32(1)
    scheduler_address::NTuple{256,Cchar} = ntuple(i->Cchar('\0'),256)
    master_address::NTuple{256,Cchar} = ntuple(i->Cchar('\0'),256)
    scheduler_pub::UInt16 = 40000
    scheduler_master::UInt16 = 40001
    scheduler_worker::UInt16 = 40002
    master_port::UInt16 = 40001
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
                           ParameterServerOptions),
                          init_c,
                          boosting_c, boost,
                          step_c, step,
                          smoothing_c, smooth,
                          prox_c, proxim,
                          proxgrad.execution.psopts)
    return proxgrad
end

include("master.jl")
include("worker.jl")
include("scheduler.jl")
