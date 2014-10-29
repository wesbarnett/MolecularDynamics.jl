module MolecularDynamics

export read_gmx, 
	   xtc_init, 
	   read_xtc, 
	   close_xtc,
	   read_ndx,
	   pbc,
	   bond_angle,
	   dih_angle,
       box_vol,
       rdf,
       prox_rdf,
       dist,
       dist2

include("Xtc.jl")
include("Ndx.jl")
include("Gmx.jl")
include("Utils.jl")

using .Xtc
using .Ndx
using .Gmx
using .Utils

end
