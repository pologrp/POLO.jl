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

include("proxgradient.jl")
include("polo_interface.jl")

end # module
