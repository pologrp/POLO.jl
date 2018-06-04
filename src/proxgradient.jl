const mylib = Libdl.dlopen(joinpath(pwd(), "install", "lib", "libapi.so"));
const proxgradient_s = Libdl.dlsym(mylib, :proxgradient_s)

struct ProxGradient{Boosting <: AbstractBoosting,
                    Step <: AbstractStep,
                    Smoothing <: AbstractSmoothing,
                    Prox <: AbstractProx}
    boosting::Boosting
    step::Step
    smoothing::Smoothing
    prox::Prox

    function (::Type{ProxGradient})(boosting::Boosting,
                                    step::Step,
                                    smoothing::Smoothing,
                                    prox::Prox) where {Boosting <: AbstractBoosting,
                                                       Step <: AbstractStep,
                                                       Smoothing <: AbstractSmoothing,
                                                       Prox <: AbstractProx}
        return new{Boosting,Step,Smoothing,Prox}(boosting,step,smoothing,prox)
    end
end

function set_boosting_params!(proxgrad::ProxGradient; kwargs...)
    reconstruct(params(proxgrad.boosting),kwargs...)
end

function boosting(proxgrad::ProxGradient)
    return proxgrad.boosting
end

function set_step_params!(proxgrad::ProxGradient; kwargs...)
    reconstruct(params(proxgrad.step),kwargs...)
end

function stepsize(proxgrad::ProxGradient)
    return proxgrad.step
end

function set_smoothing_params!(proxgrad::ProxGradient; kwargs...)
    reconstruct(params(proxgrad.smoothing),kwargs...)
end

function smoothing(proxgrad::ProxGradient)
    return proxgrad.smoothing
end

function set_prox_params!(proxgrad::ProxGradient; kwargs...)
    reconstruct(params(proxgrad.prox),kwargs...)
end

function prox(proxgrad::ProxGradient)
    return proxgrad.prox
end

function (proxgrad::ProxGradient)(x₀::AbstractVector,loss::AbstractLoss)
    xbegin = pointer(x₀, 1)
    xend = pointer(x₀, length(x₀) + 1)

    ccall(proxgradient_s, Void,
          (Ptr{Cdouble}, Ptr{Cdouble},
           Ptr{Void}, Any,
           Ptr{Void},
           Ptr{Void}, Any,
           Ptr{Void}, Any,
           Ptr{Void}, Any,
           Ptr{Void}, Any),
          xbegin, xend,
          loss_c, loss,
          init_c,
          boosting_c, boosting(proxgrad),
          step_c, stepsize(proxgrad),
          smoothing_c, smoothing(proxgrad),
          prox_c, prox(proxgrad))
end