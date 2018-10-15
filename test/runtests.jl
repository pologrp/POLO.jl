using POLO
using Test
using LinearAlgebra

@info "Loading loss functions..."
loss_functions = [("Least squares", Loss.LeastSquares(100,10)),
                  ("Log loss", Loss.LogLoss(100,10))]

solvers = [("Gradient descent", POLO.GradientDescent()),
           ("Momentum descent", POLO.MomentumDescent()),
           ("Nesterov descent", POLO.NesterovDescent()),
           ("Adagrad", POLO.AdaGrad()),
           ("Adadelta", POLO.AdaDelta()),
           ("BB", POLO.BB())]

@info "Loss functions loaded. Starting test sequence."
@testset "$sname Solver on loss function $name" for (sname,solver) in solvers, (name,loss) in loss_functions
    solver(rand(Loss.nfeatures(loss)), loss, Utility.GradientNorm(1e-6), Utility.None())
    g = copy(getx!(solver))
    Loss.loss!(loss, getx(solver), g)
    @test norm(g) <= 1e-6
end

macro TestPOLOSolver(alg)
    serial = Symbol(alg,:_s)
    algname = Symbol(titlecase(string(alg)))
    quote
        solvername = string($(Meta.quot(algname)))
        @testset "POLO Solvers: $solvername on loss function $name" for (name, loss) in loss_functions
            solver = POLOSolvers.$algname()
            solver(rand(Loss.nfeatures(loss)), loss, Utility.GradientNorm(1e-6), Utility.None())
            g = copy(solver.x)
            Loss.loss!(loss, solver.x, g)
            @test norm(g) <= 1e-6
        end
    end
end

@TestPOLOSolver(gradient)
@TestPOLOSolver(momentum)
@TestPOLOSolver(nesterov)
@TestPOLOSolver(adagrad)
@TestPOLOSolver(adadelta)

include("/usr/share/julia/test/testenv.jl")
push!(test_exeflags.exec,"--color=yes")
cmd = `env JULIA_NUM_THREADS=4 $test_exename $test_exeflags run_shm_tests.jl`

if !success(pipeline(cmd; stdout=stdout, stderr=stderr)) && ccall(:jl_running_on_valgrind,Cint,()) == 0
    error("Distributed test failed, cmd : $cmd")
end
