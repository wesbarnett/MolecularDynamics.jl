# James W. Barnett
# jbarnet4@tulane.edu
# Module for reading in Gromacs index files.

# Simply call "read_ndx(filename)" and a dictionary containing
# the locations for each index group is returned. The names of the 
# index group are the keys to the dictionary.

module Ndx

export read_ndx

function read_ndx(filename)

    title_tmp = Array(String,100)
    title_line_tmp = Array(Int,100)
    title_count = 0
    loc_tmp = Int64[]
    f = open(filename)
    all_lines = readlines(f)
    close(f)

    no_lines = size(all_lines,1)

    f = open(filename)

    for I in 1:no_lines

        # Read the line
        line = readline(f)

        # Check if it is a title
        if line[1] == '['
            title_count += 1
            title_tmp[title_count] = line[3:end-3]
            title_line_tmp[title_count] = I
        end

    end

    close(f)

    title = Array(String,title_count)
    title = title_tmp[1:title_count]

    title_line = Array(Int,title_count)
    title_line = title_line_tmp[1:title_count]

    ndx_dict = Dict()

    f = open(filename)

    line_array = 0
    K = 0
    locs = Int[]

    for I in 1:no_lines

        # Read the title line
        if in(I,title_line)
            # Populate dictionary
            if K > 0
                ndx_dict[title[K]] = locs
            end
            K += 1
            line = readline(f)
            locs = Int[]
        # Populate the locs array for the dictionary
        else
            line_array = readline(f)
            for J in 5:5:length(line_array)
                push!(locs,parseint(Int,line_array[J-4:J]))
            end
        end

    end

    # add the last key
    ndx_dict[title[end]] = locs

    close(f)

    return ndx_dict

end

end
