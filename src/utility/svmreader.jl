function _svmreader(files::Vector{<:AbstractString}, ::Type{Index}, ::Type{Value}) where {Index,Value}
  labelmask = r"^(?<val>-?\d)"
  featmask = r"(?<idx>\d+):(?<val>\d+\.\d+)"
  row = Index(1)
  rows, cols, vals, labels = Vector{Index}(), Vector{Index}(), Vector{Value}(), Vector{Value}()
  for file in files
    open(file, "r") do io
      for line in eachline(io)
        m = match(labelmask, line)
        push!(labels, parse(Float64, m[:val]))
        for m in eachmatch(featmask, line)
          push!(rows, row)
          push!(cols, parse(Int, m[:idx]))
          push!(vals, parse(Float64, m[:val]))
        end
        row += one(Index)
      end
    end
  end
  return rows, cols, vals, labels
end

function svmreader(files::Vector{<:AbstractString}, ::Type{Index}, ::Type{Value}) where {Index,Value}
  rows, cols, vals, labels = _svmreader(files, Index, Value)
  return sparse(rows, cols, vals), labels
end

function svmreader(files::Vector{<:AbstractString}, m, n, ::Type{Index}, ::Type{Value}) where {Index, Value}
  rows, cols, vals, labels = _svmreader(files, Index, Value)
  return sparse(rows, cols, vals, m, n), labels
end

svmreader(files::Vector{<:AbstractString}) = svmreader(files, Int, Float64)
svmreader(files::Vector{<:AbstractString}, m, n) = svmreader(files, m, n, Int, Float64)

svmreader(file::AbstractString) = svmreader([file])
svmreader(file::AbstractString, ::Type{Index}, ::Type{Value}) where {Index, Value} = svmreader([file], Index, Value)
svmreader(file::AbstractString, m, n) = svmreader([file], m, n)
svmreader(file::AbstractString, m, n, ::Type{Index}, ::Type{Value}) where {Index, Value} = svmreader([file], m, n, Index, Value)
