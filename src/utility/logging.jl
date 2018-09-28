abstract type LogLevel end

abstract type Value <: LogLevel end
abstract type Decision <: LogLevel end
abstract type Gradient <: LogLevel end
abstract type Full <: LogLevel end

module SimpleLogger

using POLO.AbstractLogger
using POLO.Utility: LogLevel, Value, Decision, Gradient, Full
import POLO.log

struct Logger{L <: LogLevel} <: AbstractLogger
    function (::Type{Logger})(::Type{L}) where L <: LogLevel
        return new{L}()
    end
end
Value() = Logger(Value)
Decision() = Logger(Decision)
Gradient() = Logger(Gradient)
Full() = Logger(Full)

function log(logger::Logger{Value},k::Integer,fval::AbstractFloat,x::AbstractVector,g::AbstractVector)
    if k == 1
        println("k    fval")
    end
    println(@sprintf("%d    %.2f",k,fval))
end

function log(logger::Logger{Decision},k::Integer,fval::AbstractFloat,x::AbstractVector,g::AbstractVector)
    if k == 1
        println("k    fval    x")
    end
    print(@sprintf("%d    %.2f   ",k,fval))
    println(x')
end

function log(logger::Logger{Gradient},k::Integer,fval::AbstractFloat,x::AbstractVector,g::AbstractVector)
    if k == 1
        println("k    fval    g")
    end
    print(@sprintf("%d    %.2f   ",k,fval))
    println(g')
end

end

module ProgressLogger

using ProgressMeter
using ProgressMeter.AbstractProgress
using POLO: AbstractTermination, AbstractLogger
using POLO.Utility: LogLevel, Value, Decision, Gradient, Full, MaxIteration, GradientNorm
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
