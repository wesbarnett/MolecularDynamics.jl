JuliaGromacsUtils
=================

These are some utilities for reading in and processing Gromacs-related file formats with the
[Julia](http://www.julialang.org)  language. Several modules are includes.

*  Gmx - the main module. Combine Xtc and Ndx functions to be able to read in an xtc file into an
   array for processing.
*  Xtc - read in xtc files.
*  Ndx - read in ndx files.
*  Utils - some misc. functions (for now).

Note that this is a work in progress and probably contains a few bugs. 

Requirements
------------

The xdrfile library is required for reading in Gromacs xtc files. You can
[download it here](http://www.gromacs.org/Downloads) (bottom of the page). Make
sure you install the library as a shared library; there is an option when you
configure the installation.

Example Usages
--------------
Here are a few ways to use these modules. The following uses "traj.xtc" and
"index.ndx" from the "examples/gmx-test" directory, but you can use any xtc file
and corresponding index file you wish. First open the REPL:

    julia

Now in the REPL import the Gmx module and the "read_gmx" function. The module must be in your [module
path](http://julia.readthedocs.org/en/latest/manual/modules/#module-paths).

    julia> import Gmx: read_gmx

Now here are a few things you can do with "read_gmx". Read in an xtc file and
save all of the data to various variables:

    julia> g = read_gmx("traj.xtc"):

Your output should look something like this:

    First frame to save: 1
    Last frame to save: 100000
    Saving every frame.
    Initializing traj.xtc
    No. of atoms = 2014
    Saving all atoms.
    Saved 101 frames.

You can now access all of the coordinates in the "g" object which has a type of
gmxType:

    juila> typeof(g)
    gmxType (constructor with 2 methods)

    julia> names(g)
    5-element Array{Symbol,1}:
     :no_frames
     :time     
     :box      
     :x        
     :natoms

How many frames were saved to "g". Note that Gromacs simulations start at time
0, which is saved to frame 1 in our arrays.

    julia> g.no_frames
    101

Time at a frame 5 (in ps):

    julia> g.time[5]
    0.8f0

The box at frame 10:

    julia> g.box[10]
    3x3 Array{Float32,2}:
     2.45527  0.0      0.0    
     0.0      2.45527  0.0    
     0.0      0.0      2.45527

Coordinates of the 5th atom at frame 20. Note that we have a special dictionary
entry "all" since no index file was specified (see below when one is).

    julia> g.x["all"][20][:,5]
    3-element Array{Float32,1}:
     1.335
     1.142
     0.591

How many atoms are in "all":

    julia> g.natoms["all"]
    2014

We can also read in an index file and specify one or more index groups to be
saved. In this case we'll save the "C" and "CH2" groups:

    julia> g = read_gmx("traj.xtc","index.ndx","C","CH2"):
    First frame to save: 1
    Last frame to save: 100000
    Saving every frame.
    Initializing traj.xtc
    No. of atoms = 2014
    Saving the following index groups:
      C (4 elements)
      CH2 (6 elements)
    Saved 101 frames.

Time, box, and no_frames are the same as before. We can now access the
coordinates for each specific group. Here's the 2nd atom in the group "C" at the
10th frame. Note that we are using the key "C" now instead of "all". We could
also use "CH2" since we read that one in as well.

    julia> g.x["C"][10][:,2]
    3-element Array{Float32,1}:
     1.328
     1.141
     0.561

If you wanted just the x-coordinate of the above:

    julia> g.x["C"][10][1,2]
    1.3280001f0

Here is how many atoms are in the CH2 group:

    julia> g.natoms["CH2"]
    6

natoms and x are made up of dictionaries, as stated previously:

    julia> g.natoms
    Dict{Any,Any} with 2 entries:
      "CH2" => 6
      "C"   => 4

    julia> g.x
    Dict{Any,Any} with 2 entries:
      "CH2" => {…
      "C"   => {…

You can also save only specific frames to the gmxType object, specifying the first frame to save, the last frame to save, and whether or not to skip frames in saving. The following:

    julia> g = read_gmx("traj.xtc",5,10,2);
    First frame to save: 5
    Last frame to save: 10
    Saving every other frame.
    Initializing traj.xtc
    No. of atoms = 2014
    Saving all atoms.
    Saved 5 frames.

An index file can be specified with groups again:

    julia> g = read_gmx("traj.xtc",5,10,2,"index.ndx","C");
    First frame to save: 5
    Last frame to save: 10
    Saving every other frame.
    Initializing ../examples/gmx-test/traj.xtc
    No. of atoms = 2014
    Saving the following index groups:
      C (4 elements)
    Saved 5 frames.

So far I've shown how to read in all the frames of an xtc file (or an index
group) and save them to a gmxType object. You can also read in the xtc file
frame-by-frame using the Xtc module:

First import and initialize the file:

    juila> import Xtc: xtc_init, read_xtc, close_xtc

    juila> stat, xtc = xtc_init("traj.xtc")
    Initializing ../examples/gmx-test/traj.xtc
    No. of atoms = 2014

    julia> stat
    0

    julia> typeof(xtc)
    xtcType (constructor with 1 method)

    juila> names(xtc)
    7-element Array{Symbol,1}:
     :natoms
     :step  
     :time  
     :box   
     :x     
     :prec  
     :xd   
    
"stat" is returned and tells if the initialization / read was successful (0 is success). "xd" is a C pointer that cannot be access from Julia and is solely used for getting the data using the C library xdrfile.

Now you can read the first frame using the xtc object above. 

    julia> stat, xtc = read_xtc(xtc)

Now you can get the info for the frame you just read in. Note that some of these
are zero element arrays for compatibility with the C library:

    julia> stat
    0

    julia> xtc.natoms
    2014

    juila> xtc.step[]
    0

    juila> xtc.time[]
    0.0f0

    juila> xtc.box
    3x3 Array{Float32,2}:
     2.47699  0.0      0.0    
     0.0      2.47699  0.0    
     0.0      0.0      2.47699

The coordinates of the first atom:

    juila> xtc.x[:,1]
    3-element Array{Float32,1}:
     1.297
     0.937
     0.483

They y-coordinate of the 3rd atom:

    juila> xtc.x[2,3]
    0.984f0

The precision:

    juila> xtc.prec[]
    1000.0f0
    
Calling "read_xtc" again will read the next frame. Note that "read_xtc" returns
a tuple with the first element giving the status of the read and the second
giving an xtcType object containing all of the above information. You could
simply place the "read_xtc" function in a loop and then do your calculations
within the loop (the Gmx module does this but simply saves everything to a
gmxType object). Once you're finished reading frames, you can close the xtc
file:

    julia> stat = close_xtc(xtc)

    julia> stat
    0

You can also use the Ndx module to probe the index file directly (the Gmx module
does this when you specify an index file and index groups).

    julia> import Ndx: read_ndx

    julia> ndx = read_ndx("index.ndx");

"read_ndx" returns a dictionary containing all of the different index groups:

    juila> keys(ndx)
    KeyIterator for a Dict{Any,Any} with 8 entries. Keys:
    "Water"
    "System"
    "CH2"
    "CH3"
    "non-Water"
    "Other"
    "C"
    "SOL"

Specifying a key returns the locations of those atoms in the xtc file:

    julia> C_locations = ndx["C"]
    4-element Array{Int64,1}:
      1
      5
      8
     11

You could then access those atoms from an xtcType object:

    juila> import Xtc: xtc_init, read_xtc, close_xtc

    julia> stat, xtc = xtc_init("traj.xtc");
    Initializing ../examples/gmx-test/traj.xtc
    No. of atoms = 2014

    juila> stat, xtc = read_xtc("traj.xtc")

These are the coordinates of just the "C" group from this frame:
    julia> xtc.x[:,C_locations]
    3x4 Array{Float32,2}:
     1.297  1.249  1.334  1.269
     0.937  1.021  1.145  1.21 
     0.483  0.601  0.638  0.762

Lastly, some example scripts that can be run outside of the REPL are located in
the "examples" folder.
