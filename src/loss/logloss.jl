struct LogLoss <: AbstractLoss
    N::Int
    d::Int
    A::Matrix{Float64}
    b::Vector{Float64}

    function (::Type{LogLoss})(N::Integer, d::Integer)
        @assert d ≥ 1 "d must be at least 1"
        @assert N ≥ d "N must be at least $(d)"

        A = randn(N, d)
        A *= 2/norm(A)
        b = Float64[rand() ≤ 0.5 ? -1. : 1. for idx in 1:N]

        new(N, d, A, b)
    end

    function (::Type{LogLoss})(dsfolder::String, range, categories::Vector{String}, nfeatures::Int)
        A, b = readrcv(dsfolder,range,categories,nfeatures)
        N, d = size(A)

        new(N, d, A, b)
    end
end

nfeatures(loss::LogLoss)    = loss.d
nsamples(loss::LogLoss)   = loss.N

function _value(x::AbstractVector{T}, A::AbstractMatrix,
  b::AbstractVector, N::Integer) where T <: Real
  temp = exp.(-b .* (A*x))
  for idx in 1:length(temp)
    @inbounds temp[idx] = isinf(temp[idx]) ? -b[idx]*dot(A[idx,:], x) :
                                            log1p(temp[idx])
  end
  return sum(temp)/N
end

function value(loss::LogLoss, x::AbstractVector{T}) where T <: Real
  N, d, A, b = loss.N, loss.d, loss.A, loss.b
  if length(x) ≠ nfeatures(loss)
    warn("value: `x` must have a length of `nfeatures(loss)`")
    throw(DomainError())
  end
  return _value(x, A, b, N)
end

function value(loss::LogLoss, x::AbstractVector{T},
  comps::AbstractVector{S}) where {T <: Real, S <: Integer}
  N, d = loss.N, loss.d
  compmin, compmax = extrema(comps)
  if length(x) ≠ nfeatures(loss)
    warn("value: `x` must have a length of `nfeatures(loss)`")
    throw(DomainError())
  elseif compmin < 1 || compmax > N
    warn("value: `comps` must lie within [1,$(N)]")
    throw(DomainError())
  end
  A, b = loss.A[comps,:], loss.b[comps]
  return _value(x, A, b, N)
end

function _gradient!(x::AbstractVector{T}, dx::AbstractVector{T},
  A::AbstractMatrix, b::AbstractVector, N::Integer) where T <: Real
  temp = exp.(-b .* (A*x))

  for idx in 1:length(temp)
    @inbounds temp[idx] = isinf(temp[idx]) ? -b[idx]/N :
                                             -b[idx]*temp[idx]/(1. + temp[idx])/N
  end

  return mul!(dx, transpose(A), temp)
end

function gradient!(loss::LogLoss, x::AbstractVector{T},
  dx::AbstractVector{T}) where T <: Real
  N, d, A, b = loss.N, loss.d, loss.A, loss.b
  if length(x) ≠ length(dx) || length(x) ≠ nfeatures(loss)
    warn("gradient!: Both `x` and `dx` must have a length of `nfeatures(loss)`")
    throw(DomainError())
  end

  return _gradient!(x, dx, A, b, N)
end

function gradient!(loss::LogLoss, x::AbstractVector{T},
  dx::AbstractVector{T}, comps::AbstractVector{S}) where {T<:Real, S<:Integer}
  N, d = loss.N, loss.d
  compmin, compmax = extrema(comps)
  if length(x) ≠ length(dx) || length(x) ≠ nfeatures(loss)
    warn("gradient!: Both `x` and `dx` must have a length of `nfeatures(loss)`")
    throw(DomainError())
  elseif compmin < 1 || compmax > N
    warn("gradient!: `comps` must lie within [1,$(N)]")
    throw(DomainError())
  end
  A, b = loss.A[comps,:], loss.b[comps]
  return _gradient!(x, dx, A, b, N)
end

function loss!(loss::LogLoss, x::AbstractVector, g::AbstractVector)
    gradient!(loss,x,g)
    return value(loss,x)
end

function readrcv(dsfolder::String, range, categories::Vector{String}, nfeatures::Int)
    # Feature files
    featurefiles = map(x->joinpath(dsfolder, x), filter(x->contains(x, "_vec_"), readdir(dsfolder)))

    # Topic files mapping documents to topics
    topicfiles = map(x->joinpath(dsfolder, x), filter(x->contains(x, ".qrels"), readdir(dsfolder)))

    startidx = first(range)
    endidx = last(range)
    N = length(range)

    # Auxilliary variables
    idx = 0
    readsamples = 0

    # Sparse matrix A
    rowindices = Vector{Int}()
    colindices = Vector{Int}()
    nzvals = Vector{Float64}()

    # Dense vector b
    b = zeros(N)

    topicmap = readdlm(topicfiles[1])
    topics = topicmap[:, 1]
    docs = topicmap[:, 2]

    for file in featurefiles
        open(file, "r") do io
            for line in eachline(io)
                idx += 1
                idx < startidx && continue
                idx > endidx && break

                readsamples += 1

                idxmatch = match(r"^(\d+)", line)
                docidx = parse(Int, idxmatch[1])

                # b vector
                docrange = searchsorted(docs, docidx)
                b[readsamples] = isempty(intersect(topics[docrange],categories)) ? -1. : 1.

                featindices = Vector{Int}()
                features = Vector{Float64}()

                for m in eachmatch(r"(\d+):(\d\.\d+)", line)
                    featidx = parse(Int, m[1])
                    featval = parse(Float64, m[2])

                    push!(featindices, featidx)
                    push!(features, featval)
                end

                append!(rowindices, fill(readsamples, length(featindices)))
                append!(colindices, featindices)
                append!(nzvals, features)
            end
        end
    end

    sparse(rowindices, colindices, nzvals, readsamples, nfeatures), b
end
