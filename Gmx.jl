# Module for reading in xtc file with libxdrfile
module Gmx

import Xtc: xtc_init, read_xtc, close_xtc

export read_gmx

type gmxType
	NO_CONFIGS
	time
	box
    x
end

type gmxGroup
	LOC
	title
	x
	NATOMS
end

#=  TODO: read in command line arguments (beginning, end, skip, xtc file).
    Also, be able to read in index file (how to do groups?)
=#

function save_xtc(gmx,CONF,xtc)

    gmx.time[CONF] = xtc.time[]
    gmx.box[:,:,CONF] = xtc.box[:,:]
    gmx.x[:,:,CONF] = xtc.x[:,:]

end


function read_gmx(xtc_file,FIRST,LAST)

    println("First frame to save: ", FIRST)
    println("Last frame to save: ", LAST)
    NO_CONFIGS = (LAST - FIRST + 1)

	(STAT, xtc) = xtc_init(xtc_file)

    gmx_tmp = gmxType(
        LAST,
        Array(Float32,LAST),
        Array(Float32,(3,3,LAST)),
        Array(Float32,(3,int64(xtc.NATOMS),LAST)) )

    # Skip frames until we get to the first frame to read in
    for CONF = 1:(FIRST-1)

		(STAT, xtc) = read_xtc(xtc)

        if STAT != 0
			break
		end

    end

    # Read and save these frames
    for CONF = FIRST:LAST

        println(CONF)

		(STAT, xtc) = read_xtc(xtc)

        if STAT != 0
            NO_CONFIGS = (CONF - FIRST + 1)
			break
		end
		
		save_xtc(gmx_tmp,CONF,xtc)

    end 

    println(string("Read in ", NO_CONFIGS, " frames."))

    # Resize the arrays
    gmx = gmxType(
        NO_CONFIGS,
        Array(Float32,NO_CONFIGS),
        Array(Float32,(3,3,NO_CONFIGS)),
        Array(Float32,(3,int64(xtc.NATOMS),NO_CONFIGS)) )

    gmx.NO_CONFIGS = NO_CONFIGS
    gmx.time = gmx_tmp.time[1:NO_CONFIGS]
    gmx.box = gmx_tmp.box[:,:,1:NO_CONFIGS]
    gmx.x = gmx_tmp.x[:,:,NO_CONFIGS]

    return gmx

end

end
