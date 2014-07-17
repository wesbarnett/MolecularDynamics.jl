# James W. Barnett
# jbarnet4@tulane.edu
# Some general purpose functions related to processing
# Gromacs files

module Utils

export pbc, 
       dih_angle

# Adjusts for periodic boundary condition. Input is a three-dimensional
# vector (the position) and the box ( 3 x 3 Array). A 3d vector is returned.
function pbc(a::Array{Float32,1},box::Array{Float32,2}) 

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

function bond_angle(i::Array{Float32,1},j::Array{Float32,1},
                    k::Array{Float32,1},box::Array{Float32,2})

    bond1 = Array(Float64,3)
    bond2 = Array(Float64,3)

    bond1 = j - i
    bond1 = pbc(bond1,box)

    bond2 = j - k
    bond2 = pbc(bond2,box)

    bond1mag = sqrt(dot(bond1,bond1))
    bond2mag = sqrt(dot(bond2,bond2))

    angle = acos(dot(bond1,bond2)/(bond1mag * bond2mag))

end

#= 
   Function calculates the torsion / dihedral angle from four atoms'
   positions. Source: Blondel and Karplus, J. Comp. Chem., Vol. 17, No. 9, 1
   132-1 141 (1 996). Note that it returns in radians.
=#
function dih_angle(i::Array{Float32,1}, j::Array{Float32,1},
                   k::Array{Float32,1}, l::Array{Float32,1},
                   box::Array{Float32,2})

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

    Amag = sqrt(dot(A,A))
    Bmag = sqrt(dot(B,B))
    Gmag = sqrt(dot(G,G))

    sin_phi = dot(cross_BA,G)/(Amag * Bmag * Gmag)
    cos_phi = dot(A,B)/(Amag * Bmag)

    #The torsion / dihedral angle, atan2 takes care of the sign
    # Argument 1 determines the sign
    phi = atan2(sin_phi,cos_phi)

    return phi

end

function dih_angle(a::Array{Float32,2},box::Array{Float32,2})

    H = Array(Float64,3)
    G = Array(Float64,3)
    F = Array(Float64,3)
    A = Array(Float64,3)
    B = Array(Float64,3)
    cross_BA = Array(Float64,3)

    H = a[:,3] - a[:,4]
    H = pbc(H,box)

    G = a[:,3] - a[:,2]
    G = pbc(G,box)
        
    F = a[:,2] - a[:,1]
    F = pbc(F,box)

    # Cross products
    A = cross(F,G)
    B = cross(H,G)
    cross_BA = cross(B,A)

    Amag = sqrt(dot(A,A))
    Bmag = sqrt(dot(B,B))
    Gmag = sqrt(dot(G,G))

    sin_phi = dot(cross_BA,G)/(Amag * Bmag * Gmag)
    cos_phi = dot(A,B)/(Amag * Bmag)

    #The torsion / dihedral angle, atan2 takes care of the sign
    # Argument 1 determines the sign
    phi = atan2(sin_phi,cos_phi)

    return phi

end

end
