const mylib = Libdl.dlopen(joinpath(dirname(@__FILE__), "../..", "install", "lib", "libapi.so"));
const proxgradient_s = Libdl.dlsym(mylib, :proxgradient_s)
const delete_proxgradient_s = Libdl.dlsym(mylib, :delete_proxgradient_s)
const run_serial = Libdl.dlsym(mylib, :run_serial)
const getf_s = Libdl.dlsym(mylib, :getf_s)
const getx_s = Libdl.dlsym(mylib, :getx_s)

struct SerialExecution <: ExecutionPolicy end

function initialize!(proxgrad::ProxGradient{SerialExecution})
    boost = POLO.boosting(proxgrad)
    step = POLO.stepsize(proxgrad)
    smooth = POLO.smoothing(proxgrad)
    proxim = POLO.prox(proxgrad)
    proxgrad.ptr =  ccall(proxgradient_s, Ptr{Void},
                          (Ptr{Void},
                           Ptr{Void}, Any,
                           Ptr{Void}, Any,
                           Ptr{Void}, Any,
                           Ptr{Void}, Any),
                          POLO.init_c,
                          POLO.boosting_c, boost,
                          POLO.step_c, step,
                          POLO.smoothing_c, smooth,
                          POLO.prox_c, proxim)
    return proxgrad
end

function destruct(proxgrad::ProxGradient{SerialExecution})
    ccall(delete_proxgradient_s, Void, (Ptr{Void},), proxgrad)
end

function (proxgrad::ProxGradient{SerialExecution})(x₀::AbstractVector,loss::AbstractLoss,termination::AbstractTermination,logger::AbstractLogger)
    proxgrad.x = x₀
    xbegin = pointer(x₀, 1)
    xend = pointer(x₀, length(x₀) + 1)
    return ccall(run_serial, Void,
                 (Ptr{Void},Ptr{Cdouble}, Ptr{Cdouble},
                  Ptr{Void}, Any,
                  Ptr{Void}, Any,
                  Ptr{Void}, Any),
                 proxgrad,
                 xbegin, xend,
                 POLO.loss_c, loss,
                 POLO.termination_c, termination,
                 POLO.log_c, logger)
end
function (proxgrad::ProxGradient{SerialExecution})(x₀::AbstractVector,loss::AbstractLoss)
    termination = POLO.Utility.MaxIteration(100)
    return proxgrad(x₀,loss,termination,POLO.Utility.ProgressLogger.Value(termination))
end
function (proxgrad::ProxGradient{SerialExecution})(x₀::AbstractVector,loss::AbstractLoss,termination::AbstractTermination)
    return proxgrad(x₀,loss,termination,POLO.Utility.ProgressLogger.Gradient(termination))
end

function getf(proxgrad::ProxGradient{SerialExecution})
    return ccall(getf_s, Cdouble, (Ptr{Void},), proxgrad)
end

function getx!(proxgrad::ProxGradient{SerialExecution})
    ccall(getx_s, Void, (Ptr{Void}, Ref{Cdouble}), proxgrad, proxgrad.x)
    return proxgrad.x
end
