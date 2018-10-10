module POLOSolvers

using POLO
using POLO: AbstractLoss, AbstractTermination, AbstractLogger

macro define_polo_algorithm(algname,execution)
    quote
        function $(esc(execution))(x₀::AbstractVector,loss::AbstractLoss,termination::AbstractTermination,logger::AbstractLogger)
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
                          Ptr{Nothing}, Any),
                         xbegin, xend,
                         loss_c, loss,
                         termination_c, termination,
                         log_c, logger)
            return x, fval
        end
    end
end
macro define_polo_paramserver_algorithm(algname,execution)
    quote
        function $(esc(execution))(x₀::AbstractVector,loss::AbstractLoss,termination::AbstractTermination,logger::AbstractLogger)
            x = x₀
            xbegin = pointer(x, 1)
            xend = pointer(x, length(x₀) + 1)
            loss_c = @cfunction(POLO.loss_wrapper, Cdouble,
                                (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Nothing}))
            fval = ccall(POLO.$(execution), Cdouble,
                         (Ptr{Cdouble}, Ptr{Cdouble},
                          Ptr{Nothing}, Any),
                         xbegin, xend,
                         loss_c, loss)
            return x, fval
        end
    end
end
macro define_polo_algorithm(algname)
    serial = Symbol(algname,:_s)
    consistent = Symbol(algname,:_mtc)
    inconsistent = Symbol(algname,:_mti)
    master = Symbol(algname,:_psm)
    worker = Symbol(algname,:_psw)
    scheduler = Symbol(algname,:_pss)
    quote
        @define_polo_algorithm($algname,$serial)
        @define_polo_algorithm($algname,$consistent)
        @define_polo_algorithm($algname,$inconsistent)
        @define_polo_paramserver_algorithm($algname,$master)
        @define_polo_paramserver_algorithm($algname,$worker)
        @define_polo_paramserver_algorithm($algname,$scheduler)
    end
end

@define_polo_algorithm(gradient)
@define_polo_algorithm(momentum)
@define_polo_algorithm(nesterov)
@define_polo_algorithm(adagrad)
@define_polo_algorithm(adadelta)
@define_polo_algorithm(adam)
@define_polo_algorithm(nadam)

end
