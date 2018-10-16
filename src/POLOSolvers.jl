module POLOSolvers

using MacroTools
using MacroTools: @q
using POLO
using POLO: AbstractLoss, AbstractTermination, AbstractLogger, ExecutionPolicy
using POLO.Execution: Serial, ParameterServerOptions, Master, Worker, Scheduler

macro define_polo_algorithm(algname, execution, paramdefs, ctypes)
    params = map(paramdef -> begin @capture(paramdef, param_Symbol::type_ = val_); param end, paramdefs)
    quote
        function $(esc(execution))(x₀::AbstractVector,loss::AbstractLoss,termination::AbstractTermination,logger::AbstractLogger; $(paramdefs...))
            xbegin = pointer(x₀, 1)
            xend = pointer(x₀, length(x₀) + 1)
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
            return fval
        end
    end
end
macro define_inconsistent_polo_algorithm(algname, execution, paramdefs, ctypes)
    params = map(paramdef -> begin @capture(paramdef, param_Symbol::type_ = val_); param end, paramdefs)
    quote
        function $(esc(execution))(x₀::AbstractVector,loss::AbstractLoss; $(paramdefs...))
            xbegin = pointer(x₀, 1)
            xend = pointer(x₀, length(x₀) + 1)
            loss_c = @cfunction(POLO.loss_wrapper, Cdouble,
                                (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Nothing}))
             fval = ccall(POLO.$(execution), Cdouble,
                         (Ptr{Cdouble}, Ptr{Cdouble},
                          Ptr{Nothing}, Any,
                          $(ctypes.args...)),
                         xbegin, xend,
                         loss_c, loss,
                         $(params...))
            return fval
        end
    end
end
macro define_polo_paramserver_algorithm(algname, execution, paramdefs, ctypes)
    params = map(paramdef -> begin @capture(paramdef, param_Symbol::type_ = val_); param end, paramdefs)
    @q begin
        function $(esc(execution))(x₀::AbstractVector,loss::AbstractLoss,poptions::Execution.ParameterServerOptions; $(paramdefs...))
            xbegin = pointer(x₀, 1)
            xend = pointer(x₀, length(x₀) + 1)
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
            return fval
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
    structname = Symbol(titlecase(string(algname)))
    @q begin
        @define_polo_algorithm($algname,$serial,$(algsplit[:kwargs]),$(prettify(algsplit[:body])))
        @define_polo_algorithm($algname,$consistent,$(algsplit[:kwargs]),$(prettify(algsplit[:body])))
        @define_inconsistent_polo_algorithm($algname,$inconsistent,$(algsplit[:kwargs]),$(prettify(algsplit[:body])))
        @define_polo_paramserver_algorithm($algname,$master,$(algsplit[:kwargs]),$(prettify(algsplit[:body])))
        @define_polo_paramserver_algorithm($algname,$worker,$(algsplit[:kwargs]),$(prettify(algsplit[:body])))
        @define_polo_paramserver_algorithm($algname,$scheduler,$(algsplit[:kwargs]),$(prettify(algsplit[:body])))

        struct $(esc(structname)){Execution <: ExecutionPolicy} <: POLOAlgorithm
            x::Vector{Float64}

            function $(esc(structname))(execution::Execution) where Execution <: ExecutionPolicy
                return new{Execution}(Vector{Float64}())
            end
        end
        # Serial
        $(esc(structname))() = $(esc(structname))(Execution.Serial())
        function (alg::$(esc(structname)){Execution})(x₀::AbstractVector,loss::AbstractLoss,termination::AbstractTermination,logger::AbstractLogger; kw...) where Execution <: Serial
            resize!(alg.x,length(x₀))
            alg.x .= x₀
            return $serial(alg.x, loss, termination, logger; kw...)
        end
        function (alg::$(esc(structname)){Execution})(x₀::AbstractVector,loss::AbstractLoss) where Execution <: Serial
            termination = POLO.Utility.MaxIteration(100)
            return alg(alg.x,loss,termination,Utility.ProgressLogger.Value(termination))
        end
        function (alg::$(esc(structname)){Execution})(x₀::AbstractVector,loss::AbstractLoss,termination::AbstractTermination) where Execution <: Serial
            return alg(alg.x,loss,termination,Utility.ProgressLogger.Gradient(termination))
        end
        # Parameter server
        function (::$(esc(structname)){Execution})(x₀::AbstractVector,loss::AbstractLoss,poptions::ParameterServerOptions; kw...) where Execution <: Master
            return $master(x₀,loss,poptions; kw...)
        end
        function (::$(esc(structname)){Execution})(x₀::AbstractVector,loss::AbstractLoss,poptions::ParameterServerOptions; kw...) where Execution <: Worker
            return $worker(x₀,loss,poptions; kw...)
        end
        function (::$(esc(structname)){Execution})(x₀::AbstractVector,loss::AbstractLoss,poptions::ParameterServerOptions; kw...) where Execution <: Scheduler
            return $scheduler(x₀,loss,poptions; kw...)
        end
    end
end

abstract type POLOAlgorithm end
@define_polo_algorithms gradient(; γ::Float64 = 1.) = (Cdouble,)
@define_polo_algorithms momentum(; μ::Float64 = 0.9, ϵ::Float64 = 1e-1, γ::Float64 = 1.) = (Cdouble,Cdouble,Cdouble)
@define_polo_algorithms nesterov(; μ::Float64 = 0.9, ϵ::Float64 = 1e-1, γ::Float64 = 1.) = (Cdouble,Cdouble,Cdouble)
@define_polo_algorithms adagrad(; γ::Float64 = 1., ϵ::Float64 = 1e-6) = (Cdouble,Cdouble)
@define_polo_algorithms adadelta(; γ::Float64 = 1., ρ::Float64 = 0.95, ϵ::Float64 = 1e-6) = (Cdouble,Cdouble,Cdouble)
@define_polo_algorithms adam(; μ::Float64 = 0.99, ϵ::Float64 = 1e-2, γ::Float64 = 1., ρ::Float64 = 0.999, ϵ_rms::Float64 = 1e-8) = (Cdouble,Cdouble,Cdouble,Cdouble,Cdouble)
@define_polo_algorithms nadam(; μ::Float64 = 0.99, ϵ::Float64 = 1e-2, γ::Float64 = 1., ρ::Float64 = 0.999, ϵ_rms::Float64 = 1e-8) = (Cdouble,Cdouble,Cdouble,Cdouble,Cdouble)

end
