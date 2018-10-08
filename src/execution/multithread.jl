# const gc_protect = Dict{Ptr{Cvoid},Any}()

# gc_protect_cb(work) = (pop!(gc_protect, work.handle, nothing); close_handle(work))

# function gc_protect_handle(obj::Any)
#     work = Compat.AsyncCondition(gc_protect_cb)
#     gc_protect[work.handle] = (work,obj)
#     work.handle
# end

# # Thread-safe zeromq callback when data is freed, passed to zmq_msg_init_data.
# # The hint parameter will be a uv_async_t* pointer.
# function gc_free_fn(data::Ptr{Cvoid}, hint::Ptr{Cvoid})
#     ccall(:uv_async_send,Cint,(Ptr{Cvoid},),hint)
# end

struct MultiThread <: ExecutionPolicy end

function initialize!(proxgrad::ProxGradient{MultiThread})
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
    proxgrad.ptr = ccall(POLO.proxgradient_mt, Ptr{Cvoid},
                         (Ptr{Cvoid},
                          Ptr{Cvoid}, Any,
                          Ptr{Cvoid}, Any,
                          Ptr{Cvoid}, Any,
                          Ptr{Cvoid}, Any),
                         init_c,
                         boosting_c, boost,
                         step_c, step,
                         smoothing_c, smooth,
                         prox_c, proxim)
    return proxgrad
end

execution_handle(::MultiThread) = POLO.run_multithread
delete_handle(::MultiThread) = POLO.delete_proxgradient_mt
getf_handle(::MultiThread) = POLO.getf_mt
getx_handle(::MultiThread) = POLO.getx_mt

# function (proxgrad::ProxGradient{MultiThread})(x₀::AbstractVector,loss::AbstractLoss,termination::AbstractTermination,logger::AbstractLogger)
#     resize!(proxgrad.x,length(x₀))
#     proxgrad.x[:] = x₀
#     xbegin = pointer(proxgrad.x, 1)
#     xend = pointer(proxgrad.x, length(x₀) + 1)
#     return ccall(execution_handle(proxgrad.execution), Nothing,
#                  (Ptr{Cvoid},Ptr{Cdouble}, Ptr{Cdouble},
#                   Ptr{Cvoid}, Any,
#                   Ptr{Cvoid}, Any,
#                   Ptr{Cvoid}, Any),
#                  proxgrad,
#                  xbegin, xend,
#                  POLO.loss_c, loss,
#                  POLO.termination_c, termination,
#                  POLO.log_c, logger)
# end
