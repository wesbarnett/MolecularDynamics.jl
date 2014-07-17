module JuliaGromacsUtils

export Gmx.read_gmx,
       Xtc.xtc_init, 
       Xtc.read_xtc, 
       Xtc.close_xtc,
       Ndx.read_ndx,
       Utils.pbc

    include("Xtc.jl")
    include("Ndx.jl")
    include("Gmx.jl")
    include("Utils.jl")

end
