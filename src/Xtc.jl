# James W. Barnett
# jbarnet4@tulane.edu
# Julia module for reading in xtc file with libxdrfile

module Xtc

export xtc_init, read_xtc, close_xtc

mutable struct xtcType
    natoms
    step
    time
    box
    x
    prec
    xd
end

function xtc_init(xtcfile)

    println(string("Initializing "), xtcfile)

    # Check if file exists
    if (~isfile(xtcfile))
        error(string(xtcfile," xtc file does not exist."))
    end

    # Get number of atoms in system
    natoms = Cint[0]
    stat = ccall( (:read_xtc_natoms,"libxdrfile"), Ptr{Int32}, (Ptr{UInt8},
        Ptr{Cint}), xtcfile, natoms)
	stat = Int(stat)
    println(string("No. of atoms = ", natoms[]))

    # Check if we actually did open the file
    if (stat != 0)
        error(string("Failure in opening ", xtcfile,"\nReturn code: ", stat))
    end

    # Get C xdrfile pointer
    xd = ccall( (:xdrfile_open,"libxdrfile"), Ptr{Nothing},
        (Ptr{UInt8},Ptr{UInt8}), xtcfile,"r")

    # Assign everything to this type
    xtc = xtcType(
        natoms,
        Cint[0],
        Cfloat[0],
        Array{Cfloat}(undef,(3,3)),
        Array{Cfloat}(undef,(3,Int(natoms[]))),
        Cfloat[0],
        xd)

    return stat, xtc

end

function read_xtc(xtc)
	# for prop in propertynames(xtc)
	# 	@show typeof(getproperty(xtc, prop))
	# end
    stat = ccall( (:read_xtc,"libxdrfile"), Ptr{Int32}, ( Ptr{Nothing}, Ptr{Cint},
        Ptr{Cint}, Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat} ), xtc.xd,
        xtc.natoms, xtc.step, xtc.time, xtc.box, xtc.x, xtc.prec)
	stat = Int(stat)

    if (stat != 0 | stat != 11)
        error("Failure in reading xtc frame.")
    end

	return stat, xtc

end

function close_xtc(xtc)

    stat = ccall( (:xdrfile_close,"libxdrfile"), Ptr{Int32}, ( Ptr{Nothing}, ), xtc.xd)
	stat = Int(stat)

	return stat

end

end
