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

#=  TODO: Comments
=#

function save_xtc(gmx,conf,xtc)

    gmx.time[conf] = xtc.time[]
    gmx.box[conf] = xtc.box[1:3,1:3]
	gmx.x["all"][conf] = xtc.x

	return gmx

end

function save_xtc_ndx(gmx,conf,xtc,locs,group)

    gmx.time[conf] = xtc.time[]
    gmx.box[conf] = xtc.box[1:3,1:3]
	gmx.x[group][conf] = xtc.x[1:3,locs]

	return gmx
end


function read_gmx(xtc_file,first,last,skip,ndx_file="0",group...)

    println("First frame to save: ", first)
    println("Last frame to save: ", last)
	if skip == 1
		println("Saving every frame.")
	elseif skip == 2
		println("Saving every other frame.")
	else
		println("Saving every ",skip,"th frame.")
	end

    no_configs = (last - first)

	(stat, xtc) = xtc_init(xtc_file)

	natoms_dict = Dict()
	x_dict = Dict()
	x_dict_tmp = Dict()
	no_groups = size(group,1)

	# if no index file is specified
	if ndx_file=="0"
  
		group = Array(String,1)
		group[1] = "all"

		# We use a dictionary for the natoms and coordinates even though
		# we know there will be only one key. This is to remain consistent
		# if we were to have multiple groups
		natoms_dict["all"] = xtc.natoms
		#x_vec_tmp = Array(Float32,3)
		#x_atom_array_tmp = Array(Any,int64(xtc.natoms))
		#fill!(x_atom_array_tmp,x_vec_tmp)
		x_atom_array_tmp = Array(Float32,(3,int64(xtc.natoms)))
		x_conf_array_tmp = Array(Any,last)
		fill!(x_conf_array_tmp,x_atom_array_tmp)
		x_dict_tmp["all"] = x_conf_array_tmp
  
	# if an index file is specified
	else

		ndx_dict = read_ndx(ndx_file)

		# Create dictionary containing number of atoms for each group
		# Also create dictionary for coordinates
		for i in group
			natoms = size(ndx_dict[i],1)
			natoms_dict[i] = natoms
			#x_vec_tmp = Array(Float32,3)
			#x_atom_array_tmp = Array(Any,int64(natoms))
			#fill!(x_atom_array_tmp,x_vec_tmp)
			x_atom_array_tmp = Array(Float32,(3,int64(natoms)))
			x_conf_array_tmp = Array(Any,last)
			fill!(x_conf_array_tmp,x_atom_array_tmp)
			x_dict_tmp[i] = x_conf_array_tmp
		end

	end

    box = Array(Float32,(3,3))
    box_array = Array(Any,last)
    fill!(box_array,box)

	gmx_tmp = gmxType(
	    last,
	    Array(Float32,last),
	    box_array,
		x_dict_tmp,
	 	natoms_dict)


    # Skip frames until we get to the first frame to read in
    for conf = 1:(first-1)

		(stat, xtc) = read_xtc(xtc)

        if stat != 0
			break
		end

    end

    # Read and save these frames
	save_frame = 1
    for conf = first:last

		#print(char(13),"Reading frame: ",conf)
		(stat, xtc) = read_xtc(xtc)

        if stat != 0
            no_configs = int( (conf - first) / skip )
			break
		end
		
		if conf % skip == 0
			if ndx_file == "0"
				gmx_tmp = save_xtc(gmx_tmp,save_frame,xtc)
			else
				for grp in 1:no_groups
					gmx_tmp = save_xtc_ndx(gmx_tmp,save_frame,xtc,ndx_dict[group[grp]],group[grp])
				end
			end
			save_frame += 1
		end

    end 

	println()
    println(string("Read in ", no_configs, " frames."))

    # Resize the arrays

    box = Array(Float32,(3,3))
    box_array = Array(Any,no_configs)
    fill!(box_array,box)

	if ndx_file == "0"

		x_vec = Array(Float32,3)
		x_atom_array = Array(Any,int64(xtc.natoms))
		fill!(x_atom_array,x_vec)
		x_conf_array = Array(Any,no_configs)
		fill!(x_conf_array,x_atom_array)
		x_dict["all"] = x_conf_array

	else

		for i in group

			#x_vec = Array(Float32,3)
			#x_atom_array = Array(Any,int64(gmx_tmp.natoms[i]))
			#fill!(x_atom_array,x_vec)
			x_atom_array = Array(Float32,(3,int64(gmx_tmp.natoms[i])))
			x_conf_array = Array(Any,no_configs)
			fill!(x_conf_array,x_atom_array)
			x_dict[i] = x_conf_array

		end

	end

	gmx = gmxType(
		no_configs,
		Array(Float32,no_configs),
		box_array,
		x_dict,
		natoms_dict )

	gmx.no_configs = no_configs
    gmx.time = gmx_tmp.time[1:no_configs]
	gmx.box[:] = gmx_tmp.box[1:no_configs]
	gmx.natoms = gmx_tmp.natoms

	for i in group
		gmx.x[i] = gmx_tmp.x[i][1:no_configs]
	end
	
    return gmx

end

end
