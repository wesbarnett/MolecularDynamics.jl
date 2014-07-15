
import Gmx: read_gmx

using ArgParse

function parse_commandline()

    s = ArgParseSettings(description = "Sample program that reads in xtc files.")

    @add_arg_table s begin
        "--file","-f"
            help = "The input xtc file"
            arg_type = String
            default = "traj.xtc"
    end

    return parse_args(s)

end

function main()

    parsed_args = parse_commandline()
    xtcfile = parsed_args["file"]
    gmx = read_gmx(xtcfile)

end
