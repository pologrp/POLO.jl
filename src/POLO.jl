module POLO

using Libdl

export
    ProxGradient,
    Execution,
    Utility,
    Boosting,
    Step,
    Smoothing,
    Prox,
    Loss,
    getf,
    getx!

include("load_library.jl")
include("policy.jl")
include("boosting/boosting.jl")
include("step/step.jl")
include("smoothing/smoothing.jl")
include("prox/prox.jl")

include("loss/loss.jl")
include("utility/utility.jl")

include("proxgradient.jl")
include("execution/execution.jl")

include("solvers.jl")

end # module
