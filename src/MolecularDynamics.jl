module MolecularDynamics

import .Xtc: xtc_init, read_xtc, close_xtc
import .Ndx: read_ndx
import .Gmx: read_gmx
import .Utils: pbc, bond_angle, dih_angle, rdf, prox_rdf, box_vol

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
       prox_rdf

include("Xtc.jl")
include("Ndx.jl")
include("Gmx.jl")
include("Utils.jl")

end
