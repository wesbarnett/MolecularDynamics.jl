import Utils: pbc

function bin(g,atom_i,atom_j,box,nbins,bin_width,r_excl2)

    dx = atom_i - atom_j
    dx = pbc(float32(dx),box)
    r2 = dot(dx,dx)
    if (r2 > r_excl2) then
        ig = int(ceil(sqrt(r2)/bin_width))
        if ig <= nbins
            g[ig] += 1.0
        end
    end

end 

function do_binning(g,gmx,nbins,bin_width,r_excl2,group1,group2,first,last)

    for frame in first:last

        for i in 1:gmx.natoms[group1]

            atom_i = gmx.x[group1][frame][:,i]

            for j in 1:gmx.natoms[group2]

                atom_j = gmx.x[group2][frame][:,j]

                bin(g,atom_i,atom_j,gmx.box[frame],nbins,bin_width,r_excl2)

            end

        end

    end 

	return g

end

