using POLO
using Test
using LinearAlgebra


@info "Loading loss functions..."
loss_functions = [("Least squares", Loss.LeastSquares(100,10)),
                  ("Log loss", Loss.LogLoss(100,10))]

solvers = [("Gradient descent", POLO.GradientDescent()),
           ("Momentum descent", POLO.MomentumDescent()),
           ("Nesterov descent", POLO.NesterovDescent()),
           ("Adagrad", POLO.Adagrad()),
           ("Adadelta", POLO.AdaDelta()),
           ("Adam", POLO.Adam()),
           ("Nadam", POLO.Nadam()),
           ("BB", POLO.BB())]

@info "Loss functions loaded. Starting test sequence."
@testset "$sname Solver on loss function $name" for (sname,solver) in solvers, (name,loss) in loss_functions
    solver(rand(Loss.nfeatures(loss)),loss,Utility.GradientNorm(1e-6),Utility.None())
    getx!(solver)
    g = copy(solver.x)
    Loss.loss!(loss, solver.x, g)
    @test norm(g) <= 1e-6
end
