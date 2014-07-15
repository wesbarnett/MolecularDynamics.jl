
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

     for i in 1:gmx.no_configs 

	 	println(string("Time (ps): ", gmx.time[i]))
		println("Coordinates: ")

		for l in keys(gmx.x)
			println(string("Group '", l,"'"))

	        for j in 1:gmx.natoms[l]
				for k in 1:3
					@printf "%12.6f" gmx.x[l][k,j,i] 
	            end
				@printf "\n"
			end

			println("Box:")
			@printf "%12.6f" gmx.box[1,1,i] 
			@printf "%12.6f" gmx.box[2,2,i] 
			@printf "%12.6f" gmx.box[3,3,i] 
			@printf "%12.6f" gmx.box[1,2,i] 
			@printf "%12.6f" gmx.box[1,3,i] 
			@printf "%12.6f" gmx.box[2,1,i] 
			@printf "%12.6f" gmx.box[2,3,i] 
			@printf "%12.6f" gmx.box[3,1,i]
			@printf "%12.6f\n" gmx.box[3,2,i]

		end

	end

end

function main()

    parsed_args = parse_commandline()

    xtcfile = parsed_args["file"]
	ndxfile = parsed_args["index"]
    first_frame = parsed_args["begin"]
    last_frame = parsed_args["end"]
	skip = parsed_args["skip"]

    gmx = read_gmx(xtcfile,first_frame,last_frame,skip,ndxfile,"C","CH2")
    #gmx = read_gmx(xtcfile,first_frame,last_frame,skip)

	output(gmx)

end

main()
