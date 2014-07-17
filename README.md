JuliaGromacsUtils
=================

These are some utilities for reading in and processing Gromacs-related file formats with the
[Julia](http://www.julialang.org)  language. Several modules are includes.

*  Gmx - the main module. Combine Xtc and Ndx functions to be able to read in an xtc file into an
   array for processing.
*  Xtc - read in xtc files.
*  Ndx - read in ndx files.
*  Utils - some misc. functions (for now).

You should check out the examples folder for more information. Specifically
check out "gmx-test" which uses the Gmx module to read in an xtc file and
outputs all of the info stored in the arrays. An example xtc file and its
corresponding gro file are in the folder as a quick comparison.

Note that this is a work in progress and probably contains many bugs. 

Requirements
------------

The xdrfile library is required for reading in Gromacs xtc files. You can
[download it here](http://www.gromacs.org/Downloads) (bottom of the page). Make
sure you install the library as a shared library; there is an option when you
configure the installation.

Example Usages
--------------
Here are a few ways to use these modules. First open the REPL:

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
