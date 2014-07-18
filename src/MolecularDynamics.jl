module MolecularDynamics

export read_gmx,
       xtc_init,
       read_xtc,
       close_xtc,
       read_ndx,
       dih_angle,
       bond_angle,
       pbc

    include("Xtc.jl")
    include("Ndx.jl")
    include("Gmx.jl")
    include("Utils.jl")

end
