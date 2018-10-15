using POLO
using Test
using LinearAlgebra

@test Threads.nthreads() == 4

macro shared_memory_tests(execution)
    quote
        execution_name = string($(Meta.quot(execution)))
        solvers = [("$execution_name Gradient descent", POLO.GradientDescent(Execution.$execution())),
                   ("$execution_name Momentum descent", POLO.MomentumDescent(Execution.$execution())),
                   ("$execution_name Nesterov descent", POLO.NesterovDescent(Execution.$execution())),
                   ("$execution_name Adagrad", POLO.AdaGrad(Execution.$execution())),
                   ("$execution_name Adadelta", POLO.AdaDelta(Execution.$execution()))]
        @testset "$sname Solver on loss function $name" for (sname,solver) in solvers, (name,loss) in loss_functions
            solver(rand(Loss.nfeatures(loss)), loss, Utility.GradientNorm(1e-6), Utility.None())
            g = copy(getx(solver))
            Loss.loss!(loss, getx(solver), g)
            @test norm(g) <= 1e-6
        end
    end
end

@info "Loading loss functions..."
loss_functions = [("Least squares", Loss.LeastSquares(100,10)),
                  ("Log loss", Loss.LogLoss(100,10))]
@info "Loss functions loaded. Starting test sequence."

@shared_memory_tests(Consistent)
@shared_memory_tests(Inconsistent)


end
