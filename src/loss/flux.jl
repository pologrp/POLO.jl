using Flux, Flux.Data.MNIST, Flux.Tracker, Statistics
using Flux: onehotbatch, onecold, throttle, crossentropy

struct FluxLoss{ftype,M,D1,D2} <: AbstractLoss
    model::M
    loss::Function
    X::D1
    Y::D2

    function (::Type{FluxLoss})(ftype, m, loss, X, Y)
        return new{ftype,typeof(m),typeof(X),typeof(Y)}(m, loss, X, Y)
    end
end

function MLPonMNIST()
    imgs = MNIST.images()
    # Stack images into one large batch
    X = hcat(float.(reshape.(imgs, :))...)
    labels = MNIST.labels()
    # One-hot-encode the labels
    Y = onehotbatch(labels, 0:9)
    m = Chain(
        Dense(28^2, 32, relu),
        Dense(32, 10),
        softmax)
    return FluxLoss(:mlpmnist, m, (x, y)->crossentropy(m(x), y), X, Y)
end

function nfeatures(loss::FluxLoss)
    return reduce(+, map(p->length(p), params(loss.model)))
end

function loss!(loss::FluxLoss, x::AbstractVector, g::AbstractVector)
    let curr = 1
        for param in params(loss.model)
            curr = update!(param, x, curr)
        end
    end
    l = loss.loss(loss.X, loss.Y)
    back!(l)
    let curr = 1
        for param in params(loss.model)
            curr = update_gradient!(param, g, curr)
        end
    end
    return l.data
end

function update!(param::TrackedArray{Float64, 1, <:AbstractVector{Float64}}, x::AbstractArray, curr::Integer)
    n = length(param)
    param.data .= x[curr:curr+n-1]
    return curr + n
end

function update!(param::TrackedArray{Float64, N, <:AbstractMatrix{Float64}}, x::AbstractArray, curr::Integer) where N
    m, n = size(param)
    param.data .= reshape(x[curr:curr+m*n-1], m, n)
    return curr + m*n
end

function update_gradient!(param::TrackedArray{Float64, 1, <:AbstractVector{Float64}}, g::AbstractArray, curr::Integer)
    n = length(param)
    g[curr:curr+n-1] = param.grad[:]
    return curr + n
end

function update_gradient!(param::TrackedArray{Float64, N, <:AbstractMatrix{Float64}}, g::AbstractArray, curr::Integer) where N
    m,n = size(param)
    g[curr:curr+m*n-1] = param.grad[:]
    return curr + m*n
end

function evaluate(loss::FluxLoss{:mplmnist})
    accuracy(x, y) = mean(onecold(loss.model(x)) .== onecold(y))
    tX = hcat(float.(reshape.(MNIST.images(:test), :))...)
    tY = onehotbatch(MNIST.labels(:test), 0:9)
    return accuracy(tX, tY)
end
