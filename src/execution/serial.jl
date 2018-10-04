const proxgradient_s = Libdl.dlsym(mylib, :proxgradient_s)
const delete_proxgradient_s = Libdl.dlsym(mylib, :delete_proxgradient_s)
const run_serial = Libdl.dlsym(mylib, :run_serial)
const getf_s = Libdl.dlsym(mylib, :getf_s)
const getx_s = Libdl.dlsym(mylib, :getx_s)

struct Serial <: ExecutionPolicy end

function initialize!(proxgrad::ProxGradient{Serial})
    boost = POLO.boosting(proxgrad)
    step = POLO.stepsize(proxgrad)
    smooth = POLO.smoothing(proxgrad)
    proxim = POLO.prox(proxgrad)
    proxgrad.ptr = ccall(proxgradient_s, Ptr{Void},
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

execution_handle(::Serial) = run_serial
delete_handle(::Serial) = delete_proxgradient_s
getf_handle(::Serial) = getf_s
getx_handle(::Serial) = getx_s
