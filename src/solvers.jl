GradientDescent(execution::ExecutionPolicy; γ = 1.) = ProxGradient(execution,Boosting.None(),Step.Constant(; γ = γ),Smoothing.None(),Prox.None())
GradientDescent(; kw...) = GradientDescent(Execution.Serial(); kw...)

MomentumDescent(execution::ExecutionPolicy; μ = 0.9, ϵ = 1e-3, γ = 1.) = ProxGradient(execution,Boosting.Momentum(; μ = μ, ϵ = ϵ),Step.Constant(; γ = γ),Smoothing.None(),Prox.None())
MomentumDescent(; kw...) = MomentumDescent(Execution.Serial(); kw...)

NesterovDescent(execution::ExecutionPolicy; μ = 0.9, ϵ = 1e-3, γ = 1.) = ProxGradient(execution,Boosting.Nesterov(; μ = μ, ϵ = ϵ),Step.Constant(; γ = γ),Smoothing.None(),Prox.None())
NesterovDescent(; kw...) = NesterovDescent(Execution.Serial(); kw...)

AdaGrad(execution::ExecutionPolicy; γ = 1., ϵ = 1e-6) = ProxGradient(execution,Boosting.None(),Step.Constant(; γ = γ),Smoothing.Adagrad(; ϵ = ϵ),Prox.None())
Adagrad(; kw...) = AdaGrad(Execution.Serial(); kw...)

AdaDelta(execution::ExecutionPolicy; γ = 1., ρ = 0.95, ϵ = 1e-6) = ProxGradient(execution,Boosting.None(),Step.Constant(; γ = γ),Smoothing.Adadelta(; ρ = ρ, ϵ = ϵ),Prox.None())
AdaDelta(; kw...) = AdaDelta(Execution.Serial(); kw...)

Adam(execution::ExecutionPolicy; μ = 0.9, ϵ = 1e-3, γ = 1., ρ = 0.9, ϵ_rms = 1e-6) = ProxGradient(execution,Boosting.Momentum(; μ = μ, ϵ = ϵ),Step.Constant(; γ = γ),Smoothing.RMSprop(; ρ = ρ, ϵ = ϵ_rms),Prox.None())
Adam(; kw...) = Adam(Execution.Serial(); kw...)

Nadam(execution::ExecutionPolicy; μ = 0.9, ϵ = 1e-3, γ = 1., ρ = 0.9, ϵ_rms = 1e-6) = ProxGradient(execution,Boosting.Nesterov(; μ = μ, ϵ = ϵ),Step.Constant(; γ = γ),Smoothing.RMSprop(; ρ = ρ, ϵ = ϵ_rms),Prox.None())
Nadam(; kw...) = Nadam(Execution.Serial(); kw...)

BB(execution::ExecutionPolicy) = ProxGradient(execution,Boosting.None(),Step.BB(),Smoothing.None(),Prox.None())
BB() = BB(Execution.Serial())
