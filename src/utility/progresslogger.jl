module ProgressLogger

using Printf
using LinearAlgebra
using ProgressMeter
using ProgressMeter: AbstractProgress
using POLO: AbstractTermination, AbstractLogger
using POLO.Utility: AbstractLogger, LogLevel, Value, Gradient, MaxIteration, GradientNorm
import POLO.log

struct Logger{L <: LogLevel, T <: AbstractTermination, P <: AbstractProgress} <: AbstractLogger
    progress::P

    function (::Type{Logger})(::Type{L},maxiter::MaxIteration) where L <: LogLevel
        return new{L,MaxIteration,Progress}(Progress(maxiter.K))
    end

    function (::Type{Logger})(::Type{L},gradnorm::GradientNorm) where L <: LogLevel
        return new{L,GradientNorm,ProgressThresh}(ProgressThresh(gradnorm.ϵ))
    end
end
Value(termination::AbstractTermination) = Logger(Value,termination)
Gradient(termination::AbstractTermination) = Logger(Gradient,termination)

function log(logger::Logger{Value,MaxIteration},k::Integer,fval::AbstractFloat,x::AbstractVector,g::AbstractVector)
    if k == 1
        logger.progress.tfirst = logger.progress.tlast = time()
    end
    ProgressMeter.next!(logger.progress,
                        showvalues = [
                            ("k",k),
                            ("f",fval)
                        ])
end

function log(logger::Logger{Value,GradientNorm},k::Integer,fval::AbstractFloat,x::AbstractVector,g::AbstractVector)
    if k == 1
        logger.progress.tfirst = logger.progress.tlast = time()
    end
    ProgressMeter.update!(logger.progress,norm(g),
                          showvalues = [
                              ("k",k),
                              ("f",fval)
                          ])
end

function log(logger::Logger{Gradient,MaxIteration},k::Integer,fval::AbstractFloat,x::AbstractVector,g::AbstractVector)
    if k == 1
        logger.progress.tfirst = logger.progress.tlast = time()
    end
    ProgressMeter.next!(logger.progress,
                        showvalues = [
                            ("k",k),
                            ("f",fval),
                            ("||g||₂",norm(g))
                        ])
end

function log(logger::Logger{Gradient,GradientNorm},k::Integer,fval::AbstractFloat,x::AbstractVector,g::AbstractVector)
    if k == 1
        logger.progress.tfirst = logger.progress.tlast = time()
    end
    normg = norm(g)
    ProgressMeter.update!(logger.progress,normg,
                          showvalues = [
                              ("k",k),
                              ("f",fval),
                              ("||g||₂",normg)
                          ])
end

end
