function initialize!(::ProxGradient) end
execution_handle(::ExecutionPolicy) = C_NULL
delete_handle(::ExecutionPolicy) = C_NULL
getf_handle(::ExecutionPolicy) = C_NULL
getx_handle(::ExecutionPolicy) = C_NULL

module Execution

using Libdl
using POLO
using POLO: ProxGradient, ExecutionPolicy, AbstractLoss, AbstractLogger, AbstractTermination, init_wrapper, boost_wrapper, step_wrapper, smooth_wrapper, prox_wrapper
using Parameters
import POLO: initialize!, execution_handle, delete_handle, getf_handle, getx_handle

include("serial.jl")
include("multithread.jl")
include("parameter_server.jl")

end
