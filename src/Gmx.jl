# James W. Barnett
# jbarnet4@tulane.edu
# Module for reading in xtc file with libxdrfile and saving to an array

module Gmx

import Xtc: xtc_init, read_xtc, close_xtc
import Ndx: read_ndx

export read_gmx

#=	gmxType is what is returned at the end of running "read_gmx"
	The variable "gmx" of gmxType is defined in "read_gmx" 
	and all the arrays are initialized there.

	no_frames	-	number of frames that were read in
                    note that time zero starts at frame 1 !!	
	time		-   the time at the current frame
					accessed by "gmx.time[frame]"
	box			-	the box of the current frame with dimensions 3 x 3
					accessed by "gmx.box[frame]"
	x			-   the cartesian coordinates of the atoms which were read in
					accessed by "gmx.x["Group"][frame][:,atom]"
					"Group" is the name of the index group from the index file, or
					it is "all" if no index file was specified.
	natoms		-   the number of atoms in each group
					accessed by "gmx.natoms["Group"]
=#

type gmxType
	no_frames::Int
	time
	box
    x
 	natoms
end

function save_xtc_frame(gmx::gmxType,frame::Int,xtc)

    gmx.time[frame] = xtc.time[]
    gmx.box[frame] = xtc.box[1:3,1:3]
	gmx.x["all"][frame] = xtc.x[1:3,:]

	return gmx

end

function save_xtc_frame_ndx(gmx::gmxType,frame::Int,xtc,locs,group::String)

    gmx.time[frame] = xtc.time[]
    gmx.box[frame] = xtc.box[1:3,1:3]
	gmx.x[group][frame] = xtc.x[1:3,locs]

	return gmx
end


function read_gmx(xtc_file::String,first::Int,last::Int,skip::Int,ndx_file::String="0",group::String...)

    println("First frame to save: ", first)
    println("Last frame to save: ", last)
	if skip == 1
		println("Saving every frame.")
	elseif skip == 2
		println("Saving every other frame.")
	else
		println("Saving every ",skip,"th frame.")
	end

    no_frames = (last - first)

	(stat, xtc) = xtc_init(xtc_file)

	natoms_dict = Dict()
	x_dict = Dict()
	x_dict_tmp = Dict()
	no_groups = size(group,1)

	# if no index file is specified
	if ndx_file=="0"
  
		# No groups were included since there was no index file
		group = Array(String,1)
		group[1] = "all"

		# We use a dictionary for the natoms and coordinates even though
		# we know there will be only one key. This is to remain consistent
		# if we were to have multiple groups
		natoms_dict["all"] = xtc.natoms
		x_dict_tmp["all"] = fill!(Array(Any,last),Array(Float32,(3,int64(xtc.natoms))))
  
	# if an index file is specified
	else

		ndx_dict = read_ndx(ndx_file)

		# Create dictionary containing number of atoms for each group
		# Also create dictionary for coordinates
		for i in group
			natoms = size(ndx_dict[i],1)
			natoms_dict[i] = natoms
			x_dict_tmp[i] = fill!(Array(Any,last),Array(Float32,(3,int64(natoms))))
		end

	end

    box_array = Array(Any,last)
    fill!(box_array,Array(Float32,(3,3)))

	gmx_tmp = gmxType(
	    last,
	    Array(Float32,last),
	    box_array,
		x_dict_tmp,
	 	natoms_dict)

    # Skip frames until we get to the first frame to read in
    for frame = 1:(first-1)

		(stat, xtc) = read_xtc(xtc)

        if stat != 0
			break
		end

    end

    # Read and save these frames
	save_frame = 1
    for frame = first:last

		if frame % 1000 == 0
			print(char(13),"Reading frame: ",frame)
		end

		(stat, xtc) = read_xtc(xtc)

        if stat != 0
            no_frames = int( (frame - first) / skip )
			break
		end
		
		if frame % skip == 0
			if ndx_file == "0"
				gmx_tmp = save_xtc_frame(gmx_tmp,save_frame,xtc)
			else
				for grp in 1:no_groups
					gmx_tmp = save_xtc_frame_ndx(gmx_tmp,save_frame,xtc,ndx_dict[group[grp]],group[grp])
				end
			end
			save_frame += 1
		end

    end 

    println(char(13),"Read in ", no_frames, " frames.")

    # Resize the arrays
    box_array = Array(Any,no_frames)
    fill!(box_array,Array(Float32,(3,3)))

	for i in group

		x_dict[i] = fill!(Array(Any,no_frames),Array(Float32,(3,int64(gmx_tmp.natoms[i]))))

	end

	gmx = gmxType(
		no_frames,
		Array(Float32,no_frames),
		box_array,
		x_dict,
		natoms_dict )

	gmx.no_frames = no_frames
    gmx.time = gmx_tmp.time[1:no_frames]
	gmx.box[:] = gmx_tmp.box[1:no_frames]
	gmx.natoms = gmx_tmp.natoms

	for i in group
		gmx.x[i] = gmx_tmp.x[i][1:no_frames]
	end
	
    return gmx

end

end
