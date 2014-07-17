module JuliaGromacsUtils

export Xtc
export Ndx
export Gmx: read_gmx
export Utils

    include("Xtc.jl")
    include("Ndx.jl")
    include("Gmx.jl")
    include("Utils.jl")

end
