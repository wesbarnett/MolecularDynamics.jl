# Module for reading in xtc file with libxdrfile
module Gmx

import Xtc: xtc_init, read_xtc, close_xtc
import Ndx: read_ndx

export read_gmx

type gmxType
	no_configs
	time
	box
    x
	natoms
end

type gmxGroup
	loc
	title
	x
	natoms
end

#=  TODO: read in command line arguments (beginning, end, skip, xtc file).
    Also, be able to read in index file (how to do groups?)
=#

function save_xtc(gmx,conf,xtc,locs)

    gmx.time[conf] = xtc.time[]
    gmx.box[:,:,conf] = xtc.box[:,:]
	gmx.x[:,:,conf] = xtc.x[:,locs]

end


function read_gmx(xtc_file,ndx_file,first,last,group...)

    println("First frame to save: ", first)
    println("Last frame to save: ", last)
    no_configs = (last - first)

	(stat, xtc) = xtc_init(xtc_file)
	ndx_dict = read_ndx(ndx_file)

	# TODO: make index file optional
	# if no index file is specified
	#=
    gmx_tmp = gmxType(
        last,
        Array(Float32,last),
        Array(Float32,(3,3,last)),
        Array(Float32,(3,int64(xtc.natoms),last)) )
	=#

	# if an index file is specified
    gmx_tmp = gmxType(
        last,
        Array(Float32,last),
        Array(Float32,(3,3,last)),
        Array(Float32,(3,size(ndx_dict[group[1]],1),last)),
		xtc.natoms)

    # Skip frames until we get to the first frame to read in
    for conf = 1:(first-1)

		(stat, xtc) = read_xtc(xtc)

        if stat != 0
			break
		end

    end

    # Read and save these frames
    for conf = first:last

		# TODO: add output counter
		(stat, xtc) = read_xtc(xtc)

        if stat != 0
            no_configs = (conf - first)
			break
		end
		
		save_xtc(gmx_tmp,conf,xtc,ndx_dict[group[1]])

    end 

    println(string("Read in ", no_configs, " frames."))

    # Resize the arrays
    gmx = gmxType(
        no_configs,
        Array(Float32,no_configs),
        Array(Float32,(3,3,no_configs)),
        Array(Float32,(3,size(ndx_dict[group[1]],1),no_configs)),
		xtc.natoms )

    gmx.no_configs = no_configs
    gmx.time = gmx_tmp.time[1:no_configs]
    gmx.box = gmx_tmp.box[:,:,1:no_configs]

    gmx.x = gmx_tmp.x[:,:,1:no_configs]
	gmx.natoms = size(ndx_dict[group[1]],1)

	println(gmx.x[:,1,1])

    return gmx

end

end
