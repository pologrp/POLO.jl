function initialize!(::ProxGradient) end
execution_handle(::ExecutionPolicy) = C_NULL
delete_handle(::ExecutionPolicy) = C_NULL
getf_handle(::ExecutionPolicy) = C_NULL
getx_handle(::ExecutionPolicy) = C_NULL

module Execution

using POLO
using POLO: ProxGradient, ExecutionPolicy, AbstractLoss, AbstractLogger, AbstractTermination
using Parameters
import POLO: initialize!, execution_handle, delete_handle, getf_handle, getx_handle

const mylib = Libdl.dlopen(joinpath(dirname(@__FILE__), "../..", "install", "lib", "libapi.so"));

include("serial.jl")
include("multithread.jl")
include("parameter_server.jl")

end
