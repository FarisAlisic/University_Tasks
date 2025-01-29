using Plots

function rocket_ode(t, u)
    y, v, w = u
    g = 32.2
    T = 8000
    D = 0.005 * g * v^2
    
    dy = v
    dv = (g / w) * (T - w - D)
    dw = -80
    return [dy, dv, dw]
end

function RungeKuttaMethod(f, u0, n, bounds)
    h = (bounds[2] - bounds[1]) / n
    t = bounds[1]
    u = u0
    solutions = [u0]
    times = [t]
    for i in 1:n
        k1 = f(t, u)
        k2 = f(t + h/2, u + h/2 * k1)
        k3 = f(t + h/2, u + h/2 * k2)
        k4 = f(t + h, u + h * k3)
        u = u + h/6 * (k1 + 2*k2 + 2*k3 + k4)
        t += h
        push!(solutions, u)
        push!(times, t)
    end
    return times, solutions
end

y0 = 0.0
v0 = 0.0
w0 = 3000.0
u0 = [y0, v0, w0]
tspan = (0.0, 3.0)
n = 1000

times, solutions = RungeKuttaMethod(rocket_ode, u0, n, tspan)
ys = [u[1] for u in solutions]
vs = [u[2] for u in solutions]
ws = [u[3] for u in solutions]
accelerations = [(32.2 / w) * (8000 - w - 0.005 * 32.2 * v^2) for (v, w) in zip(vs, ws)]

p1 = plot(times, ys, label="Position (y)", xlabel="Time (s)", ylabel="y (ft)", title="Position of the Rocket")
p2 = plot(times, vs, label="Velocity (v)", xlabel="Time (s)", ylabel="v (ft/s)", title="Velocity of the Rocket")
p3 = plot(times, accelerations, label="Acceleration (a)", xlabel="Time (s)", ylabel="a (ft/s²)", title="Acceleration of the Rocket")

plot(p1, p2, p3, layout = (3, 1), size = (800, 600))

savefig("Task2")