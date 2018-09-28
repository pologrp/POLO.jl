function initialize!(::ProxGradient) end
function getf(::ProxGradient) end
function getx!(::ProxGradient) end

module Execution

using POLO
using POLO: ProxGradient, ExecutionPolicy, AbstractLoss, AbstractLogger, AbstractTermination
import POLO: initialize!, getf, getx!

include("serial.jl")

end
