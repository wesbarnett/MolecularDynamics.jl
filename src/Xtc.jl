# James W. Barnett
# jbarnet4@tulane.edu
# Julia module for reading in xtc file with libxdrfile

module Xtc

export xtc_init, read_xtc, close_xtc

type xtcType
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
    isfile(xtcfile) || error(string(xtcfile," xtc file does not exist."))

    # Get number of atoms in system
    natoms = Cint[0]
    stat = ccall( (:read_xtc_natoms,"libxdrfile"), Int32, (Ptr{Uint8},
        Ptr{Cint}), xtcfile, natoms)
    println(string("No. of atoms = ", natoms[]))

    # Check if we actually did open the file
    stat == 0 || error(string("Failure in opening ", xtcfile))

    # Get C xdrfile pointer
    xd = ccall( (:xdrfile_open,"libxdrfile"), Ptr{Void},
        (Ptr{Uint8},Ptr{Uint8}), xtcfile,"r")

    # Assign everything to this type
    xtc = xtcType(
        natoms[],
        Cint[0],
        Cfloat[0],
        Array(Cfloat,(3,3)),
        Array(Cfloat,(3,int64(natoms[]))),
        Cfloat[0],
        xd)

    return stat, xtc

end

function read_xtc(xtc)

    stat = ccall( (:read_xtc,"libxdrfile"), Int32, ( Ptr{Void}, Ptr{Cint},
        Ptr{Cint}, Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat} ), xtc.xd,
        xtc.natoms, xtc.step, xtc.time, xtc.box, xtc.x, xtc.prec) 

    if (stat != 0 | stat != 11)
        error("Failure in reading xtc frame.")
    end

	return stat, xtc

end

function close_xtc(xtc)

    stat = ccall( (:xdrfile_close,"libxdrfile"), Int32, ( Ptr{Void}, ), xtc.xd)
    if (stat == 0)
        println("Closed ", xtcfile,".")
    else
        println("Error closing ", xtcfile,"!")
    end

	return stat

end

end
