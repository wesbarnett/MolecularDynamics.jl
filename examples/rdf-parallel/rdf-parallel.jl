# James W. Barnett
# jbarnet4@tulane.edu
# Creates a radial distribution function given two groups (in this case "C" and
# "OW", which can be changed by the user in the main function. Note that this
# program only works with a constant volume system and with a box that is cubic.

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
        "--outfile","-o"
            help = "Data output file."
            arg_type = String
            default = "rdf.dat"
        "--plotfile","-p"
            help = "Plot output file."
            arg_type = String
            default = "plot.svg"
		"--group1","--g1"
			help = "The name of index group 1."
			arg_type = String
			default = "C"
		"--group2","--g2"
			help = "The name of index group 2."
			arg_type = String
			default = "OW"
    end

    return parse_args(s)

end

function normalize(g,gmx,nbins,bin_width,group1,group2)

    bin_vols = zeros(Float64, nbins)
    for i in 1:nbins
        r = float(i)  + 0.5
        bin_vol = r^3 - (r-1.0)^3
        bin_vol *= 4.0/3.0 * pi * (bin_width)^3 
		# TODO: only works if we have a constant volume with a cubic box
        g[i] *= float64(gmx.box[1][1,1] * gmx.box[1][2,2] * gmx.box[1][3,3]) / ( gmx.natoms[group1] * gmx.natoms[group2] * bin_vol * gmx.no_frames) 
    end

end

function output(g,bin_width,outfile,plotfile)

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
    savefig(plotfile)

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
    plotfile = parsed_args["plotfile"]
    outfile = parsed_args["outfile"]
    group1 = parsed_args["group1"]
    group2 = parsed_args["group2"]
    
    r_excl2 = r_excl^2

    gmx = read_gmx(xtcfile,first_frame,last_frame,skip,ndxfile,group1,group2)

    # TODO: this is only for a constant volume cubic box
    nbins =  iround( gmx.box[1][1,1] / (2.0 * bin_width) )

    g = zeros(Float64,nbins)

    # Have to keep this in a separate file so that it is available to all
    # processes
    require("do_binning.jl")

    np = nprocs()
    size = ceil(gmx.no_frames / np)
    rrefs = {}
    g_tmp = {}

    # Spawn processes
    for i in 1:np

        first = size*(i-1)+1
        last = size*i

        if last > gmx.no_frames
            last = gmx.no_frames
        end

        push!(rrefs, @spawn do_binning(g,gmx,nbins,bin_width,r_excl2,group1,group2,first,last) )

    end

    # Wait for and fetch results
    while length(rrefs) > 0
        push!(g_tmp,fetch(pop!(rrefs)))
    end

    # Combine together
    for i in 1:np
        for j in 1:nbins
            g[j] += g_tmp[i][j]
        end
    end

    println(char(13),"Binning complete.        ")
    normalize(g,gmx,nbins,bin_width,group1,group2)

    output(g,bin_width,outfile,plotfile)

end

main()
