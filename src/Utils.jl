# James W. Barnett
# jbarnet4@tulane.edu
# Some general purpose functions related to processing
# Gromacs files

module Utils

export pbc

# Adjusts for periodic boundary condition. Input is a three-dimensional
# vector (the position) and the box ( 3 x 3 Array). A 3d vector is returned.
function pbc(a,box) 

    b = Array(Float64,3)
	box_inv = Array(Float64,3)
	shift = Float64

    box_inv[1] = 1.0/box[1,1]
    box_inv[2] = 1.0/box[2,2]
    box_inv[3] = 1.0/box[3,3]

    # z
    shift = iround(a[3] * box_inv[3])
    b[3] = a[3] - box[3,3] * shift
    b[2] = a[2] - box[3,2] * shift
    b[1] = a[1] - box[3,1] * shift

    # y
    shift = iround(a[2] * box_inv[2])
    b[2] = a[2] - box[2,2] * shift
    b[1] = a[1] - box[2,1] * shift

    # x
    shift = iround(a[1] * box_inv[1])
    b[1] = a[1] - box[1,1] * shift

	return b

end

# Returns the torsion / dihedral angle consisting of four atoms
function dih_ang(i,j,k,l,box)

    H = Array(Float64,3)
    G = Array(Float64,3)
    F = Array(Float64,3)
    A = Array(Float64,3)
    B = Array(Float64,3)
    cross_BA = Array(Float64,3)

    H = k - l
    H = pbc(H,box)

    G = k - j
    G = pbc(G,box)
        
    F = j - i
    F = pbc(F,box)

    # Cross products
    A = cross(F,G)
    B = cross(H,G)
    cross_BA = cross(B,A)

    sin_phi = dot(cross_BA,G)/(Amag * Bmag * Gmag)
    cos_phi = dot(A,B)/(Amag * Bmag)

    #The torsion / dihedral angle, atan2 takes care of the sign
    # Argument 1 determines the sign
    phi = atan2(sin_phi,cos_phi)

    return phi

end

end
