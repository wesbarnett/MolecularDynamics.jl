# James W. Barnett
# jbarnet4@tulane.edu
# Some general purpose functions related to processing
# Gromacs files

module Utils

export pbc, 
       dih_angle,
	   bond_angle,
       rdf,
       prox_rdf,
	   box_vol

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

# Returns bond angle using the input of three atoms' coordinates. Angle
# is in radians
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

    return angle

end

function bond_angle(a::Array{Float32,2},box::Array{Float32,2})

	angle = Float64[]

	for i in 1:size(a,2)-2

		angle = push!(angle,bond_angle(a[:,i],a[:,i+1],a[:,i+2],box))

	end

	return angle

end

# Cycles through all frames
function bond_angle(f::Array{Any,1},box::Array{Any,1})


    angles = Array(Float64,(size(f[1],2)-2,1))
	angles = bond_angle(f[1],box[1])

	for i in 2:size(f,1)

		angles = hcat(angles,bond_angle(f[i],box[i]))

	end

    return angles

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

# Cycles through sequence of dihedral angles
function dih_angle(a::Array{Float32,2},box::Array{Float32,2})

	angle = Float64[]

	for i in 1:size(a,2)-3

		angle = push!(angle,dih_angle(a[:,i],a[:,i+1],a[:,i+2],a[:,i+3],box))

	end

	return angle

end

# Cycles through all frames
function dih_angle(f::Array{Any,1},box::Array{Any,1})


    angles = Array(Float64,(size(f[1],2)-3,1))
	angles = dih_angle(f[1],box[1])

	for i in 2:size(f,1)

		angles = hcat(angles,dih_angle(f[i],box[i]))

	end

    return angles

end

function box_vol(box::Array{Float32,2})

    vol = (box[1,1] * box[2,2] * box[3,3] +
           box[1,2] * box[2,3] * box[3,1] +
           box[1,3] * box[2,1] * box[3,2] - 
           box[1,3] * box[2,2] * box[3,1] +
           box[1,2] * box[2,1] * box[3,3] +
           box[1,1] * box[2,3] * box[3,2] )

    return vol

end

function bin_rdf(g,atom_i,atom_j,box,nbins::Int,bin_width::Float64,r_excl2::Float64)

    dx = atom_i - atom_j
    dx = pbc(float32(dx),box)
    r2 = dot(dx,dx)
    if (r2 > r_excl2) then
        ig = iround(ceil(sqrt(r2)/bin_width))
        if ig <= nbins
            g[ig] += 1.0
        end
    end

    return g

end 

function normalize_rdf(g,gmx,nbins::Int,bin_width::Float64,group1::String,group2::String)

    bin_vols = zeros(Float64, nbins)
    for i in 1:nbins
        r = float(i)  + 0.5
        bin_vol = r^3 - (r-1.0)^3
        bin_vol *= 4.0/3.0 * pi * (bin_width)^3 
		# TODO: only works if we have a constant volume with a cubic box
        if group1 == group2
            g[i] *= float64(box_vol(gmx.box[1])) / ( (gmx.natoms[group1] - 1) * gmx.natoms[group2] * bin_vol * gmx.no_frames) 
        else
            g[i] *= float64(box_vol(gmx.box[1])) / ( gmx.natoms[group1] * gmx.natoms[group2] * bin_vol * gmx.no_frames) 
        end
    end

    bin = Array(Float64,size(g,1))

    for i in 1:size(g,1)
        bin[i] = float(i) * bin_width
    end

    return bin,g

end

function do_rdf_binning(g,gmx,nbins::Int,bin_width::Float64,r_excl2::Float64,group1::String,group2::String)

    for frame in 1:gmx.no_frames

        if frame % 1000 == 0
		    print(char(13),"Binning frame: ",frame)
        end

        for i in 1:gmx.natoms[group1]

            atom_i = gmx.x[group1][frame][:,i]

            for j in 1:gmx.natoms[group2]

                atom_j = gmx.x[group2][frame][:,j]

                bin_rdf(g,atom_i,atom_j,gmx.box[frame],nbins,bin_width,r_excl2)

            end

        end

    end 

    return g

end

# Radial distribution function
# TODO: this is only for a constant volume cubic box
function rdf(gmx,group1::String,group2::String,bin_width=0.002::Float64,r_excl=0.1::Float64)

    println("WARNING: this function only works for a constant volume cubic box.")
    r_excl2 = r_excl^2

    nbins =  iround( gmx.box[1][1,1] / (2.0 * bin_width) )

    g = zeros(Float64,nbins)

    g = do_rdf_binning(g,gmx,nbins,bin_width,r_excl2,group1,group2)

    println(char(13),"Binning complete.        ")
    g = normalize_rdf(g,gmx,nbins,bin_width,group1,group2)

    return g

end

function rdf(gmx,group1::String,bin_width=0.002::Float64,r_excl=0.1::Float64)

    g = rdf(gmx,group1,group1,bin_width,r_excl)

    return g

end

function do_prox_rdf_binning(g,gmx,nbins::Int,bin_width::Float64,r_excl2::Float64,group1::String,group2::String)

    nsites = gmx.natoms[group1]
    test_vec = Array(Float64,3)
    test_mag = Array(Float64,nsites)
    g_tmp = zeros(Float64,nbins)
    bin_vols = Array(Float64,nbins)

    for frame in 1:gmx.no_frames

        if frame % 1000 == 0
		    print(char(13),"Binning frame: ",frame)
        end

        for i in 1:gmx.natoms[group2]

            atom_i = gmx.x[group1][frame][:,i]

            for j in 1:gmx.nsites

                atom_j = gmx.x[group1][frame][:,j]
                test_vec = atom_i - atom_j
                test_vec = pbc(test_vec,gmx.box[frame])
                test_mag[j] = sqrt(dot(test_vec,test_vec))

            end

            site = indmin(test_mag)
            atom_j = gmx.x[group1][frame][:,site]
            bin_rdf(g,atom_i,atom_j,gmx.box[frame],nbins,bin_width,r_excl2)

        end

        vol = box_vol(gmx.box[frame])
        bin_vols = calc_prox_vol(g,gmx,frame)

        g_tmp += g * vol / bin_vols + g_tmp
        g = zeros(Float64,nbins)

    end 

    g = g_tmp / (gmx.no_frames * gmx.natoms[group2] * nsites)

    return g

end

function calc_prox_vol(g,gmx,group1,frame)

    nrand = 1000
    nsites = gmx.natoms[group1]
    tot_points = nrand * nsites

    test_mag = Array(Float64,nsites)

    do bin = 1, nbins

        point_count = 0

        do site = 1, nsites

            do i = 1, nrand

                myrand = rand(3)
                theta = myrand[1] * pi
                phi = myrand[2] * 2.0 * pi
                r = myrand[3] * bin_width (float(bin)-1.0) * bin_width

                x = r * sin(theta) * cos(phi)
                y = r * sin(theta) * sin(phi)
                z = r * cos(theta)

                point = [x, y, z]

                do j = 1, nsites

                    test_vec = point - gmx.x[group1][frame]
                    test_vec = pbc(test_vec,gmx.box[frame])
                    test_mag(j) = sqrt(dot(test_vec,test_vec))

                end

                if (indmin(test_mag) == site)
                    point_count += 1
                end

            end

        end

        r = float[bin] + 0.5
        bin_vols[bin] = r^3 - (r-1.0)^3
        bin_vols[bin] *= 4.0/3.0 * pi * (bin_width)^3

        bin_vols[bin] *= ( float(point_count) / float(tot_points) )

    end

    return bin_vols

end

function prox_rdf(gmx,group1::String,group2::String,bin_width=0.002::Float64,r_excl=0.1::Float64)

    println("WARNING: this function only works for a constant volume cubic box.")
    r_excl2 = r_excl^2

    nbins =  iround( gmx.box[1][1,1] / (2.0 * bin_width) )

    g = zeros(Float64,nbins)

    g = do_prox_rdf_binning(g,gmx,nbins,bin_width,r_excl2,group1,group2)

end
