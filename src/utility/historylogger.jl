module HistoryLogger

using Printf
using RecipesBase
using Statistics
using POLO
using POLO: AbstractLogger
using POLO.Utility: LogLevel, Value, Decision, Gradient, Full, SimpleLogger
import POLO.log

struct History{L <: POLO.AbstractLogger} <: AbstractLogger
    fhist::Vector{Float64}
    inner::L

    function (::Type{History})()
        return new{SimpleLogger.Logger{None}()}(Vector{Float64}(), SimpleLogger.None())
    end

    function (::Type{History})(::Type{L}) where L <: LogLevel
        return new{SimpleLogger.Logger{L}}(Vector{Float64}(), SimpleLogger.Logger(L))
    end

    function (::Type{History})(logger::AbstractLogger)
        return new{typeof(logger)}(Vector{Float64}(), logger)
    end
end

function log(logger::History,k::Integer,fval::AbstractFloat,x::AbstractVector,g::AbstractVector)
    push!(logger.fhist,fval)
    log(logger.inner,k,fval,x,g)
end

@recipe function f(logger::History)
    length(logger.fhist) > 0 || error("No solution data. Has solver been run?")
    fmin = minimum(logger.fhist)
    fmax = maximum(logger.fhist)
    increment = std(logger.fhist)

    linewidth --> 4
    linecolor --> :black
    tickfontsize := 14
    tickfontfamily := "sans-serif"
    guidefontsize := 16
    guidefontfamily := "sans-serif"
    titlefontsize := 22
    titlefontfamily := "sans-serif"
    xlabel := "k"
    ylabel := "f"
    ylims --> (fmin-increment,fmax+increment)
    xlims --> (1,length(logger.fhist)+1)
    xticks --> 1:5:length(logger.fhist)
    yticks --> fmin:increment:fmax
    xformatter := (d) -> @sprintf("%.1f",d)
    yformatter := (d) -> begin
        if abs(d) <= sqrt(eps())
            "0.0"
        elseif (log10(abs(d)) < -2.0 || log10(abs(d)) > 3.0)
            @sprintf("%.4e",d)
        elseif log10(abs(d)) > 2.0
            @sprintf("%.1f",d)
        else
            @sprintf("%.2f",d)
        end
    end

    @series begin
        seriescolor --> :black
        1:1:length(logger.fhist),logger.fhist
    end
end

end
