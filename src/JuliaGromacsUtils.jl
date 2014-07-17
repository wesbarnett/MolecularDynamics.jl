module JuliaGromacsUtils

export Xtc.xtc_init, 
       Xtc.read_xtc, 
       Xtc.close_xtc,
       Ndx.read_ndx,
       Gmx.read_gmx,
       Utils.pbc

    include("Xtc.jl")
    include("Ndx.jl")
    include("Gmx.jl")
    include("Utils.jl")

end
