module SimpleLogger

using Printf
using POLO: AbstractLogger
using POLO.Utility: LogLevel, None, Value, Decision, Gradient, Full
import POLO.log

struct Logger{L <: LogLevel} <: AbstractLogger
    function (::Type{Logger})()
        return new{None}()
    end

    function (::Type{Logger})(::Type{L}) where L <: LogLevel
        return new{L}()
    end
end
None() = Logger()
Value() = Logger(Value)
Decision() = Logger(Decision)
Gradient() = Logger(Gradient)
Full() = Logger(Full)

function log(logger::Logger{None},k::Integer,fval::AbstractFloat,x::AbstractVector,g::AbstractVector)
    nothing
end

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
