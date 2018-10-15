struct Serial <: ExecutionPolicy
    fval::Float64
    x::Vector{Float64}

    function (::Type{Serial})()
        return new(0., Vector{Float64}())
    end
end

function initialize!(serial::Serial, x₀::AbstractVector)
    resize!(serial.x,length(x₀))
    serial.x .= x₀
end
getx(serial::Serial) = serial.x

function initialize!(proxgrad::ProxGradient{Serial})
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
    proxgrad.ptr = ccall(POLO.proxgradient_s, Ptr{Cvoid},
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

execution_handle(::Serial) = POLO.run_serial
delete_handle(::Serial) = POLO.delete_proxgradient_s
getf_handle(::Serial) = POLO.getf_s
getx_handle(::Serial) = POLO.getx_s
