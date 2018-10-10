abstract type LogLevel end

abstract type None <: LogLevel end
abstract type Value <: LogLevel end
abstract type Decision <: LogLevel end
abstract type Gradient <: LogLevel end
abstract type Full <: LogLevel end

include("simplelogger.jl")
include("progresslogger.jl")
include("historylogger.jl")

History() = HistoryLogger.History()
History(::Type{L}) where L <: LogLevel = HistoryLogger.History(L)
History(logger::AbstractLogger) = HistoryLogger.History(logger)
