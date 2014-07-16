# James W. Barnett
# jbarnet4@tulane.edu
# Creates a radial distribution function given two groups (in this case "C" and
# "OW", which can be changed by the user in the main function.

import Gmx: read_gmx
import Utils: pbc

using ArgParse
using PyPlot

function parse_commandline()

    s = ArgParseSettings(description = "Creates a radial distribution function
        from two sets of molecules/atoms.")

    @add_arg_table s begin
        "--file","-f"
            help = "The input xtc file."
            arg_type = String
            default = "traj.xtc"
		"--index","-n"
            help = "The index file."
            arg_type = String
            default = "index.ndx"
        "--begin","-b"
            help = "First frame to read in from xtc file."
            arg_type = Int
            default = 1
        "--end","-e"
            help = "Last frame to read in from xtc file."
            arg_type = Int
            default = 100000
		"--skip","-s"
            help = "Save only every nth frame."
            arg_type = Int
            default = 1
        "--bin-width"
            help = "Width of bin (nm) for rdf."
            arg_type = Float64
            default = 0.002
        "--r-excl"
            help = "Exclusion distance."
            arg_type = Float64
            default = 0.1
    end

    return parse_args(s)

end

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

function normalize(g,gmx,nbins,bin_width,group1,group2)

    bin_vols = zeros(Float64, nbins)
    for i in 1:nbins
        r = float(i)  + 0.5
        bin_vols[i] = r^3 - (r-1.0)^3
        bin_vols[i] *= 4.0/3.0 * pi * (bin_width)^3 
    end

    # TODO: only works if we have a constant volume with a cubic box
    for i in 1:nbins
        g[i] *= float64(gmx.box[1][1,1] * gmx.box[1][2,2] * gmx.box[1][3,3]) / ( gmx.natoms[group1] * gmx.natoms[group2] * bin_vols[i] * gmx.no_frames) 
    end

end

function output(g,bin_width,outfile)

    f = open(outfile, "w")

    bin = Array(Float64,size(g,1))

    for i in 1:size(g,1)
        bin[i] = float(i) * bin_width
		@printf(f,"%12.6f",bin[i])
		@printf(f,"%12.6f\n",g[i])
    end
    close(f)

    plot(bin, g, color="red", linewidth=2.0, linestyle="solid")
    title("Radial Distribution Function")
    savefig("plot.svg")

end

function do_binning(g,gmx,nbins,bin_width,r_excl2,group1,group2)

    for frame in 1:gmx.no_frames

		print(char(13),"Binning frame: ",frame)

        for i in 1:gmx.natoms[group1], j in 1:gmx.natoms[group2]

            atom_i = gmx.x[group1][frame][:,i]
            atom_j = gmx.x[group2][frame][:,j]

            bin(g,atom_i,atom_j,gmx.box[frame],nbins,bin_width,r_excl2)

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
    bin_width = parsed_args["bin-width"]
    r_excl = parsed_args["r-excl"]

    r_excl2 = r_excl^2

    group1 = "C"
    group2 = "OW"

    gmx = read_gmx(xtcfile,first_frame,last_frame,skip,ndxfile,group1,group2)

    # TODO: this is only for a constant volume cubic box
    nbins =  iround( gmx.box[1][1,1] / (2.0 * bin_width) )

    g = zeros(Float64,nbins)

    do_binning(g,gmx,nbins,bin_width,r_excl2,group1,group2)

    println(char(13),"Binning complete.        ")
    normalize(g,gmx,nbins,bin_width,group1,group2)

    output(g,bin_width,"rdf.dat")

end

main()
