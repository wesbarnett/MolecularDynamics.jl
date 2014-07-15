# James W. Barnett (c) 2014
# jbarnet4@tulane.edu
# Julia module for reading in xtc file with libxdrfile

module Xtc

export xtc_init, read_xtc, close_xtc, read_gmx

type xtcType
    NATOMS
    STEP
    time
    box
    x
    prec
    xd
end

function xtc_init(xtcfile) 

    println(string("Initializting "), xtcfile)

    # Check if file exists
    if (~isfile(xtcfile)) 
        error(string(xtcfile," xtc file does not exist."))
    end

    # Get number of atoms in system
    NATOMS = Cint[0]
    STAT = ccall( (:read_xtc_natoms,"libxdrfile"), Int32, (Ptr{Uint8},
        Ptr{Cint}), xtcfile, NATOMS)
    println(string("No. of atoms = ", NATOMS[]))

    # Check if we actually did open the file
    if (STAT != 0)
        error(string("Failure in opening ", xtcfile))
    end

    # Get C xdrfile pointer
    xd = ccall( (:xdrfile_open,"libxdrfile"), Ptr{Void},
        (Ptr{Uint8},Ptr{Uint8}), xtcfile,"r")

    # Assign everything to this type
    xtc = xtcType(
        NATOMS[],
        Cint[0],
        Cfloat[0],
        Array(Cfloat,(3,3)),
        Array(Cfloat,(3,int64(NATOMS[]))),
        Cfloat[0],
        xd)

    return STAT, xtc

end

function read_xtc(xtc)

    STAT = ccall( (:read_xtc,"libxdrfile"), Int32, ( Ptr{Void}, Ptr{Cint},
        Ptr{Cint}, Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat} ), xtc.xd,
        xtc.NATOMS, xtc.STEP, xtc.time, xtc.box, xtc.x, xtc.prec) 

    if (STAT != 0 | STAT != 11)
        error("Failure in reading xtc frame.")
    end

	return STAT, xtc

end

function close_xtc(xtc)

    STAT = ccall( (:xdrfile_close,"libxdrfile"), Int32, ( Ptr{Void}, ), xtc.xd)

	return STAT

end

end
