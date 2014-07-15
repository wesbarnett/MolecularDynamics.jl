
import Gmx: read_gmx

using ArgParse

function parse_commandline()

    s = ArgParseSettings(description = "Sample program that reads in xtc files.")

    @add_arg_table s begin
        "--file","-f"
            help = "The input xtc file"
            arg_type = String
            default = "traj.xtc"
        "--begin","-b"
            help = "First frame to read in from xtc file"
            arg_type = Int
            default = 1
        "--end","-e"
            help = "Last frame to read in from xtc file"
            arg_type = Int
            default = 100000
    end

    return parse_args(s)

end

function main()

    parsed_args = parse_commandline()

    xtcfile = parsed_args["file"]
    FIRST = parsed_args["begin"]
    LAST = parsed_args["end"]

    gmx = read_gmx(xtcfile,FIRST,LAST)

end

main()
