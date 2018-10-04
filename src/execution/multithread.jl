const proxgradient_mt = Libdl.dlsym(mylib, :proxgradient_mt)
const delete_proxgradient_mt = Libdl.dlsym(mylib, :delete_proxgradient_mt)
const run_multithread = Libdl.dlsym(mylib, :run_multithread)
const getf_mt = Libdl.dlsym(mylib, :getf_mt)
const getx_mt = Libdl.dlsym(mylib, :getx_mt)

# const gc_protect = Dict{Ptr{Void},Any}()

# gc_protect_cb(work) = (pop!(gc_protect, work.handle, nothing); close_handle(work))

# function gc_protect_handle(obj::Any)
#     work = Compat.AsyncCondition(gc_protect_cb)
#     gc_protect[work.handle] = (work,obj)
#     work.handle
# end

# # Thread-safe zeromq callback when data is freed, passed to zmq_msg_init_data.
# # The hint parameter will be a uv_async_t* pointer.
# function gc_free_fn(data::Ptr{Void}, hint::Ptr{Void})
#     ccall(:uv_async_send,Cint,(Ptr{Void},),hint)
# end

struct MultiThread <: ExecutionPolicy end

function initialize!(proxgrad::ProxGradient{MultiThread})
    boost = POLO.boosting(proxgrad)
    step = POLO.stepsize(proxgrad)
    smooth = POLO.smoothing(proxgrad)
    proxim = POLO.prox(proxgrad)
    proxgrad.ptr = ccall(proxgradient_mt, Ptr{Void},
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

execution_handle(::MultiThread) = run_multithread
delete_handle(::MultiThread) = delete_proxgradient_mt
getf_handle(::MultiThread) = getf_mt
getx_handle(::MultiThread) = getx_mt

# function (proxgrad::ProxGradient{MultiThread})(x₀::AbstractVector,loss::AbstractLoss,termination::AbstractTermination,logger::AbstractLogger)
#     resize!(proxgrad.x,length(x₀))
#     proxgrad.x[:] = x₀
#     xbegin = pointer(proxgrad.x, 1)
#     xend = pointer(proxgrad.x, length(x₀) + 1)
#     return ccall(execution_handle(proxgrad.execution), Void,
#                  (Ptr{Void},Ptr{Cdouble}, Ptr{Cdouble},
#                   Ptr{Void}, Any,
#                   Ptr{Void}, Any,
#                   Ptr{Void}, Any),
#                  proxgrad,
#                  xbegin, xend,
#                  POLO.loss_c, loss,
#                  POLO.termination_c, termination,
#                  POLO.log_c, logger)
# end
