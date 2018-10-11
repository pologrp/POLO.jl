module POLOSolvers

using MacroTools
using MacroTools: @q
using POLO
using POLO: AbstractLoss, AbstractTermination, AbstractLogger

macro define_polo_algorithm(algname, execution, paramdefs, ctypes)
    params = map(paramdef -> begin @capture(paramdef, param_Symbol::type_ = val_); param end, paramdefs)
    quote
        function $(esc(execution))(x₀::AbstractVector,loss::AbstractLoss,termination::AbstractTermination,logger::AbstractLogger; $(paramdefs...))
            x = x₀
            xbegin = pointer(x, 1)
            xend = pointer(x, length(x₀) + 1)
            loss_c = @cfunction(POLO.loss_wrapper, Cdouble,
                                (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Nothing}))
            termination_c = @cfunction(POLO.termination_wrapper, Cint,
                                       (Cint, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Nothing}))
            log_c = @cfunction(POLO.log_wrapper, Nothing,
                               (Cint, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Nothing}))
            fval = ccall(POLO.$(execution), Cdouble,
                         (Ptr{Cdouble}, Ptr{Cdouble},
                          Ptr{Nothing}, Any,
                          Ptr{Nothing}, Any,
                          Ptr{Nothing}, Any,
                          $(ctypes.args...)),
                         xbegin, xend,
                         loss_c, loss,
                         termination_c, termination,
                         log_c, logger,
                         $(params...))
            return x, fval
        end
    end
end
macro define_inconsistent_polo_algorithm(algname, execution, paramdefs, ctypes)
    params = map(paramdef -> begin @capture(paramdef, param_Symbol::type_ = val_); param end, paramdefs)
    quote
        function $(esc(execution))(x₀::AbstractVector,loss::AbstractLoss; $(paramdefs...))
            x = x₀
            xbegin = pointer(x, 1)
            xend = pointer(x, length(x₀) + 1)
            loss_c = @cfunction(POLO.loss_wrapper, Cdouble,
                                (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Nothing}))
             fval = ccall(POLO.$(execution), Cdouble,
                         (Ptr{Cdouble}, Ptr{Cdouble},
                          Ptr{Nothing}, Any,
                          $(ctypes.args...)),
                         xbegin, xend,
                         loss_c, loss,
                         $(params...))
            return x, fval
        end
    end
end
macro define_polo_paramserver_algorithm(algname, execution, paramdefs, ctypes)
    params = map(paramdef -> begin @capture(paramdef, param_Symbol::type_ = val_); param end, paramdefs)
    @q begin
        function $(esc(execution))(x₀::AbstractVector,loss::AbstractLoss,poptions::Execution.ParameterServerOptions; $(paramdefs...))
            x = x₀
            xbegin = pointer(x, 1)
            xend = pointer(x, length(x₀) + 1)
            loss_c = @cfunction(POLO.loss_wrapper, Cdouble,
                                (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Nothing}))
            fval = ccall(POLO.$(execution), Cdouble,
                         (Ptr{Cdouble}, Ptr{Cdouble},
                          Ptr{Nothing}, Any,
                          Ptr{Nothing},
                          $(ctypes.args...)),
                         xbegin, xend,
                         loss_c, loss,
                         options,
                         $(params...))
            return x, fval
        end
    end
end
macro define_polo_algorithms(alg)
    algsplit = splitdef(alg)
    algname = algsplit[:name]
    serial = Symbol(algname,:_s)
    consistent = Symbol(algname,:_mtc)
    inconsistent = Symbol(algname,:_mti)
    master = Symbol(algname,:_psm)
    worker = Symbol(algname,:_psw)
    scheduler = Symbol(algname,:_pss)
    @q begin
        @define_polo_algorithm($algname,$serial,$(algsplit[:kwargs]),$(prettify(algsplit[:body])))
        @define_polo_algorithm($algname,$consistent,$(algsplit[:kwargs]),$(prettify(algsplit[:body])))
        @define_inconsistent_polo_algorithm($algname,$inconsistent,$(algsplit[:kwargs]),$(prettify(algsplit[:body])))
        @define_polo_paramserver_algorithm($algname,$master,$(algsplit[:kwargs]),$(prettify(algsplit[:body])))
        @define_polo_paramserver_algorithm($algname,$worker,$(algsplit[:kwargs]),$(prettify(algsplit[:body])))
        @define_polo_paramserver_algorithm($algname,$scheduler,$(algsplit[:kwargs]),$(prettify(algsplit[:body])))
    end
end

@define_polo_algorithms gradient(; γ::Float64 = 1.) = (Cdouble,)
@define_polo_algorithms momentum(; μ::Float64 = 0.9, ϵ::Float64 = 1e-1, γ::Float64 = 1.) = (Cdouble,Cdouble,Cdouble)
@define_polo_algorithms nesterov(; μ::Float64 = 0.9, ϵ::Float64 = 1e-1, γ::Float64 = 1.) = (Cdouble,Cdouble,Cdouble)
@define_polo_algorithms adagrad(; γ::Float64 = 1., ϵ::Float64 = 1e-6) = (Cdouble,Cdouble)
@define_polo_algorithms adadelta(; γ::Float64 = 1., ρ::Float64 = 0.95, ϵ::Float64 = 1e-6) = (Cdouble,Cdouble,Cdouble)
@define_polo_algorithms adam(; μ::Float64 = 0.99, ϵ::Float64 = 1e-2, γ::Float64 = 1., ρ::Float64 = 0.999, ϵ_rms::Float64 = 1e-8) = (Cdouble,Cdouble,Cdouble,Cdouble,Cdouble)
@define_polo_algorithms nadam(; μ::Float64 = 0.99, ϵ::Float64 = 1e-2, γ::Float64 = 1., ρ::Float64 = 0.999, ϵ_rms::Float64 = 1e-8) = (Cdouble,Cdouble,Cdouble,Cdouble,Cdouble)

end
