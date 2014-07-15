# Read in an print out xtc file contents

import Xtc: xtc_init, read_xtc, close_xtc
require("argparse")
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "-f","--file"
            help = "The input file"
            arg_type = String
            default = "traj.xtc"
    end

    return parse_args(s)

end

function main() 


    parsed_args = parse_commandline()

    (STAT, xtc) = xtc_init("traj.xtc")

     while (STAT == 0) 

        (STAT, xtc) = read_xtc(xtc)

	 	println(string("Time (ps): ", xtc.time[], " Step: ", xtc.STEP[]))

	 	println("Coordinates: ")
        for J in 1:xtc.NATOMS
            for I in 1:3
                @printf "%12.6f" xtc.x[I,J] 
            end
            @printf "\n"
        end

        @printf "%12.6f" xtc.box[1,1] 
        @printf "%12.6f" xtc.box[2,2] 
        @printf "%12.6f" xtc.box[3,3] 
        @printf "%12.6f" xtc.box[1,2] 
        @printf "%12.6f" xtc.box[1,3] 
        @printf "%12.6f" xtc.box[2,1] 
        @printf "%12.6f" xtc.box[2,3] 
        @printf "%12.6f" xtc.box[3,1]
        @printf "%12.6f\n" xtc.box[3,2]

     end

    close_xtc(xtc)

end

main()
