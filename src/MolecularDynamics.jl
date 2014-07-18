module MolecularDynamics

include("Xtc.jl")
include("Ndx.jl")
include("Gmx.jl")
include("Utils.jl")

import .Xtc: xtc_init, read_xtc, close_xtc
import .Ndx: read_ndx
import .Gmx: read_gmx
import .Utils: pbc, bond_angle, dih_angle, rdf

export read_gmx, 
	   xtc_init, 
	   read_xtc, 
	   close_xtc,
	   read_ndx,
	   pbc,
	   bond_angle,
	   dih_angle

end
