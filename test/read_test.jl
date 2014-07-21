
gmx = read_gmx("../examples/gmx-test/traj.xtc","../examples/gmx-test/index.ndx","C")

if (gmx.x["C"][2][1,3] == 1.315 &
	gmx.natoms["4"] == 4 &
	gmx.no_frames == 101)
	stat = 0
else
	stat = 1
end

return stat
