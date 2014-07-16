JuliaGromacsUtils
=================

These are some utilities for reading in and processing Gromacs-related file formats with the
Julia language. Several modules are includes.

*  Gmx - the main module. Combine Xtc and Ndx functions to be able to read in an xtc file into an
   array for processing.
*  Xtc - read in xtc files.
*  Ndx - read in ndx files.
*  Utils - some misc. functions (for now).

You should check out the examples folder for more information.

Note that this is a work in progress and probably contains many bugs. 

Requirements
------------

The xdrfile library is required for reading in Gromacs xtc files. You can
[download it here](http://www.gromacs.org/Downloads) (bottom of the page).
