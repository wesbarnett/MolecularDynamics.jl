
using MolecularDynamics

gmx = read_gmx("examples/gmx-test/traj.xtc","examples/gmx-test/index.ndx","C")

test = Array(Bool,3)

test[1] = isequal(string(gmx.x["C"][2][1,3]),"1.315")
test[2] = isequal(gmx.natoms["C"],4)
test[3] = isequal(gmx.no_frames,101)

if (all(test))
	stat = 0
else
	stat = 1
end

return stat
