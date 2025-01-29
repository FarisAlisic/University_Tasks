using Plots

function system(t, X)
    x1, x2, x3, x4 = X
    dx1 = x3
    dx2 = x4
    dx3 = -x1 * (x1^2 + x2^2)^(-3/2)
    dx4 = -x2 * (x1^2 + x2^2)^(-3/2)
    return [dx1, dx2, dx3, dx4]
end

function heun_method(f, X0, steps, interval)
    h = (interval[2] - interval[1]) / steps
    t_values = range(interval[1], stop=interval[2], length=steps+1)
    results = zeros(length(X0), length(t_values))
    results[:, 1] = X0
    
    for i in 1:steps
        t0 = t_values[i]
        K1 = f(t0, results[:, i])
        K2 = f(t0 + h, results[:, i] + h * K1)
        results[:, i + 1] = results[:, i] + h/2 * (K1 + K2)
    end
    
    return t_values, results
end

initial_conditions = [1.0, 0.0, 0.0, 1.0]
steps = 1000
interval = (0.0, 2π)
t_values, results = heun_method(system, initial_conditions, steps, interval)

plot(t_values, results[1, :], label = "x1(t)", xlabel = "t", ylabel = "Values")
plot!(t_values, results[2, :], label = "x2(t)")
plot!(t_values, results[3, :], label = "x3(t)")
plot!(t_values, results[4, :], label = "x4(t)", title = "Solutions of the System Using Heun's Method")

savefig("Task1")