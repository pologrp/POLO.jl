using POLO: loss!, boost!, stepsize, smooth!, prox!, terminate, log
using LinearAlgebra
import POLO: getf, getx!
import Base: copyto!

abstract type MultiThread <: ExecutionPolicy end

mutable struct Consistent <: MultiThread
    mutex::Threads.Mutex
    k::Int
    fval::Float64
    x::Vector{Float64}
    g::Vector{Float64}

    function (::Type{Consistent})()
        return new(Threads.Mutex(),1,0.,Vector{Float64}(),Vector{Float64}())
    end
end

getk(consistent::Consistent) = consistent.k
getf(consistent::Consistent) = consistent.fval
setf!(consistent::Consistent, fval::AbstractFloat) = consistent.fval = fval
readx(consistent::Consistent) = consistent.x
readg(consistent::Consistent) = consistent.g
increment(consistent::Consistent) = consistent.k += 1

function initialize!(consistent::Consistent, x₀::AbstractVector)
    consistent.k = 1
    consistent.fval = 0.
    resize!(consistent.x,length(x₀))
    consistent.x .= x₀
    resize!(consistent.g,length(x₀))
    consistent.g .= zeros(length(x₀))
end

mutable struct Inconsistent <: MultiThread
    k::Threads.Atomic{Int}
    fval::Threads.Atomic{Float64}
    x::Vector{Threads.Atomic{Float64}}
    g::Vector{Threads.Atomic{Float64}}

    function (::Type{Inconsistent})()
        return new(Threads.Atomic{Int}(1),Threads.Atomic{Float64}(0.),Vector{Threads.Atomic{Float64}}(),Vector{Threads.Atomic{Float64}}())
    end
end

function copyto!(::IndexStyle, dest::AbstractArray{<:Threads.Atomic}, ::IndexStyle, src::AbstractArray)
    destinds, srcinds = LinearIndices(dest), LinearIndices(src)
    isempty(srcinds) || (checkbounds(Bool, destinds, first(srcinds)) && checkbounds(Bool, destinds, last(srcinds))) ||
        throw(BoundsError(dest, srcinds))
    @inbounds for i in srcinds
        dest[i][] = src[i]
    end
    return dest
end

getk(inconsistent::Inconsistent) = inconsistent.k[]
getf(inconsistent::Inconsistent) = inconsistent.fval[]
setf!(inconsistent::Inconsistent, fval::AbstractFloat) = inconsistent.fval[] = fval
readx(inconsistent::Inconsistent) = getindex.(inconsistent.x)
readg(inconsistent::Inconsistent) = getindex.(inconsistent.g)
increment(inconsistent::Inconsistent) = Threads.atomic_add!(inconsistent.k, 1)

function initialize!(inconsistent::Inconsistent, x₀::AbstractVector)
    inconsistent.k[] = 1.
    inconsistent.fval[] = 0.
    resize!(inconsistent.x,length(x₀))
    inconsistent.x .= Threads.Atomic{Float64}.(x₀)
    resize!(inconsistent.g,length(x₀))
    inconsistent.g .= Threads.Atomic{Float64}.(0.)
end

function (proxgrad::ProxGradient{<:MultiThread})(x₀::AbstractVector, loss::AbstractLoss, termination::AbstractTermination, logger::AbstractLogger)
    initialize!(proxgrad, x₀)

    Threads.@threads for i = 1:Threads.nthreads()
        kernel(proxgrad, Threads.threadid(), loss, termination, logger)
    end
end

getf(proxgrad::ProxGradient{<:MultiThread}) = getf(proxgrad.execution)
getx!(proxgrad::ProxGradient{<:MultiThread}) = nothing
getx(multithread::MultiThread) = readx(multithread)

function kernel(proxgrad::ProxGradient{<:MultiThread}, wid::Integer, loss::AbstractLoss, termination::AbstractTermination, logger::AbstractLogger)
    xlocal::Vector{Float64} = zeros(length(proxgrad.execution.x))
    glocal::Vector{Float64} = zeros(length(proxgrad.execution.g))

    read!(proxgrad, xlocal)
    flocal::Float64 = loss!(loss, xlocal, glocal)
    while true
        klocal::Int = getk(proxgrad.execution)
        if !iterate!(proxgrad, wid, klocal, flocal, glocal, termination, logger)
            return nothing
        end
        read!(proxgrad, xlocal)
        flocal = loss!(loss, xlocal, glocal)
    end
end

function iterate!(proxgrad::ProxGradient{<:MultiThread}, wid::Integer, klocal::Integer, flocal::Float64, glocal::AbstractVector, termination::AbstractTermination, logger::AbstractLogger, ::Val{false})
    k = getk(proxgrad.execution)
    x = proxgrad.execution.x
    g = proxgrad.execution.g
    if terminate(termination, k, flocal, readx(proxgrad.execution), glocal)
        setf!(proxgrad.execution, flocal)
        return false
    end
    boost!(POLO.boosting(proxgrad), wid, klocal, k, glocal, g)
    smooth!(POLO.smoothing(proxgrad), klocal, k, readx(proxgrad.execution), readg(proxgrad.execution), g)
    η = stepsize(POLO.stepsize(proxgrad), klocal, k, flocal, readx(proxgrad.execution), readg(proxgrad.execution))
    prox!(POLO.prox(proxgrad), η, readx(proxgrad.execution), readg(proxgrad.execution), x)
    increment(proxgrad.execution)
    return true
end
function iterate!(proxgrad::ProxGradient{Inconsistent}, wid::Integer, klocal::Integer, flocal::Float64, glocal::AbstractVector, termination::AbstractTermination, logger::AbstractLogger)
    res = iterate!(proxgrad, wid, klocal, flocal, glocal, termination, logger, Val{false}())
    if wid == 1
        log(logger, klocal, flocal, readx(proxgrad.execution), readg(proxgrad.execution))
    end
    return res
end

function iterate!(proxgrad::ProxGradient{<:MultiThread}, wid::Integer, klocal::Integer, flocal::Float64, glocal::AbstractVector, termination::AbstractTermination, logger::AbstractLogger, ::Val{true})
    lock(proxgrad.execution.mutex)
    res = iterate!(proxgrad, wid, klocal, flocal, glocal, termination, logger, Val{false}())
    log(logger, klocal, flocal, readx(proxgrad.execution), readg(proxgrad.execution))
    unlock(proxgrad.execution.mutex)
    return res
end
iterate!(proxgrad::ProxGradient{Consistent}, wid::Integer, klocal::Integer, flocal::Float64, glocal::AbstractVector, termination::AbstractTermination, logger::AbstractLogger) = iterate!(proxgrad, wid, klocal, flocal, glocal, termination, logger, Val{true}())

function read!(proxgrad::ProxGradient{<:MultiThread}, xlocal::AbstractVector, ::Val{false})
    xlocal .= readx(proxgrad.execution)
end
read!(proxgrad::ProxGradient{Inconsistent}, xlocal::AbstractVector) = read!(proxgrad, xlocal, Val{false}())

function read!(proxgrad::ProxGradient{<:MultiThread}, xlocal::AbstractVector, ::Val{true})
    lock(proxgrad.execution.mutex)
    read!(proxgrad, xlocal, Val{false}())
    unlock(proxgrad.execution.mutex)
end
read!(proxgrad::ProxGradient{Consistent}, xlocal::AbstractVector) = read!(proxgrad, xlocal, Val{true}())
