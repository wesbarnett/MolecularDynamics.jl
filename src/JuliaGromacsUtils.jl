module JuliaGromacsUtils

export xtc_init, 
       read_xtc, 
       close_xtc,
       read_ndx,
       read_gmx,
       pbc

    include("Xtc.jl")
    include("Ndx.jl")
    include("Gmx.jl")
    include("Utils.jl")

end
