module POLO

export
    ProxGradient,
    Boosting,
    Step,
    Smoothing,
    Prox,
    Loss

include("policy.jl")
include("boosting/boosting.jl")
include("step/step.jl")
include("smoothing/smoothing.jl")
include("prox/prox.jl")

include("loss/loss.jl")

include("proxgradient.jl")

end # module
