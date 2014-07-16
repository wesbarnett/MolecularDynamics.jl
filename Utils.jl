module Utils

export pbc

function pbc(a,box) 

	box_inv = Array(Float32,3)
	shift = Float32

    box_inv[1] = 1.0/box[1,1]
    box_inv[2] = 1.0/box[2,2]
    box_inv[3] = 1.0/box[3,3]

    # z
    shift = iround(a[3] * box_inv[3])
    a[3] = a[3] - box[3,3] * shift
    a[2] = a[2] - box[3,2] * shift
    a[1] = a[1] - box[3,1] * shift

    # y
    shift = iround(a[2] * box_inv[2])
    a[2] = a[2] - box[2,2] * shift
    a[1] = a[1] - box[2,1] * shift

    # x
    shift = iround(a[1] * box_inv[1])
    a[1] = a[1] - box[1,1] * shift

    #get_mag(a)

	return a
end

function get_mag(a)

	a.mag = sqrt(dot_product(a, a)) 

	return a

end

end
