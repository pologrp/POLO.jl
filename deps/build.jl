using BinaryProvider

products = Product[
  LibraryProduct("/usr/local/lib", "libpoloapi", :libpolo),
]

if any(!satisfied(p) for p in products)
  error("POLO is not installed properly on your system.")
end

write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
