module JuliaGromacsUtils

export Gmx: read_gmx
export Xtc: xtc_init, read_xtc, close_xtc
export Ndx: read_ndx
export Utils: pbc

    include("Xtc.jl")
    include("Ndx.jl")
    include("Gmx.jl")
    include("Utils.jl")

end
