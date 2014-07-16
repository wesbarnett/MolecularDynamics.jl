# James W. Barnett
# jbarnet4@tulane.edu
# Test program to show how an xtc file and ndx file can be read in using
# "read_gmx".

# ArgParse is required so you'll need to add that with the package manager:
#   Pkg.add("ArgParse")
# You'll also need to make sure the Gmx module is in your module path. You can
# the directory containing this module to the JULIA_LOAD_PATH environmental
# variable.

import Gmx: read_gmx

using ArgParse

function parse_commandline()

    s = ArgParseSettings(description = "Sample program that reads in xtc files.")

    @add_arg_table s begin
        "--file","-f"
            help = "The input xtc file"
            arg_type = String
            default = "traj.xtc"
		"--index","-n"
            help = "The index file"
            arg_type = String
            default = "index.ndx"
        "--begin","-b"
            help = "First frame to read in from xtc file"
            arg_type = Int
            default = 1
        "--end","-e"
            help = "Last frame to read in from xtc file"
            arg_type = Int
            default = 100000
		"--skip","-s"
            help = "Save only every nth frame."
            arg_type = Int
            default = 1
    end

    return parse_args(s)

end

function output(gmx)

     for frame in 1:gmx.no_frames 

	 	println(string("Time (ps): ", gmx.time[frame]))
		println("Coordinates: ")

		for group in keys(gmx.x)
			println(string("Group '", group,"'"))

	        for atom in 1:gmx.natoms[group]
				for k in 1:3
					@printf "%12.6f" gmx.x[group][frame][k,atom]
	            end
				@printf "\n"
			end

		end

		println("Box:")
		@printf "%12.6f" gmx.box[frame][1,1] 
		@printf "%12.6f" gmx.box[frame][2,2] 
		@printf "%12.6f" gmx.box[frame][3,3] 
		@printf "%12.6f" gmx.box[frame][1,2] 
		@printf "%12.6f" gmx.box[frame][1,3] 
		@printf "%12.6f" gmx.box[frame][2,1] 
		@printf "%12.6f" gmx.box[frame][2,3] 
		@printf "%12.6f" gmx.box[frame][3,1]
		@printf "%12.6f\n" gmx.box[frame][3,2]

	end

end

function main()

    parsed_args = parse_commandline()

    xtcfile = parsed_args["file"]
	ndxfile = parsed_args["index"]
    first_frame = parsed_args["begin"]
    last_frame = parsed_args["end"]
	skip = parsed_args["skip"]

    # read_gmx can be used with or without an ndxfile

    # With an index file with one group
    #gmx = read_gmx(xtcfile,first_frame,last_frame,skip,ndxfile,"C")

    # With an index file with multiple groups
    #gmx = read_gmx(xtcfile,first_frame,last_frame,skip,ndxfile,"C","CH2")

    # No index file
    gmx = read_gmx(xtcfile,first_frame,last_frame,skip)

    output(gmx)

end

main()
