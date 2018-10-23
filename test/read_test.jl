
using MolecularDynamics

gmx = read_gmx(joinpath(@__DIR__,"../examples/gmx-test/traj.xtc"),joinpath(@__DIR__,"../examples/gmx-test/index.ndx"),"C")

test = Array{Bool}(undef,3)

println()
println("Testing libxdrfile reading...")

print("Test 1...")
test[1] = isequal(string(gmx.x["C"][2][1,3]),"1.315")
if (test[1])
    print("passed.\n")
else
    print("failed.\n")
end

print("Test 2...")
test[2] = isequal(gmx.natoms["C"],4)
if (test[2])
    print("passed.\n")
else
    print("failed.\n")
end

print("Test 3...")
test[3] = isequal(gmx.no_frames,101)
if (test[3])
    print("passed.\n")
else
    print("failed.\n")
end

if (all(test))
    println("All tests passed.")
	stat = 0
else
    println("Some tests failed.")
	stat = 1
end

return stat
