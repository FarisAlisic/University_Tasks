using Plots
using LinearAlgebra

# Given constants
g = 9.81
l = 1.0
theta0 = pi / 4  # 45 degrees
omega0 = 0.0
T = 10.0
steps = 1000

# The system of first-order ODEs without damping
f(t, z) = [z[2], -g/l * sin(z[1])]

# Initial condition
z0 = [theta0, omega0]

# Time array
t = range(0, T, length=steps + 1)

# Implement numerical methods
function explicit_euler(f, z0, steps, a, b)
    h = (b - a) / steps
    z = [z0]
    for i in 1:steps
        x = a + (i - 1) * h
        push!(z, z[end] .+ h .* f(x, z[end]))
    end
    return z
end

function implicit_euler(f, z0, steps, a, b; tol_f=1e-15, tol_x=1e-15, max_iter=1000)
    h = (b - a) / steps
    z = [z0]
    for i in 1:steps
        g(x) = x .- z[end] .- h .* f(a + i * h, x)
        x0, x1 = z[end], z[end] .+ 1e-6
        for j in 1:max_iter
            fx0, fx1 = g(x0), g(x1)
            if norm(fx1) == norm(fx0)
                x_new = x1
            else
                x_new = x1 .- (x1 - x0) .* fx1 ./ (fx1 - fx0)
            end
            if norm(x_new - x1) <= tol_x || norm(g(x_new)) <= tol_f
                push!(z, x_new)
                break
            end
            x0, x1 = x1, x_new
            if j == max_iter
                error("Newton method failed to converge")
            end
        end
    end
    return z
end

function modified_euler(f, z0, steps, a, b)
    h = (b - a) / steps
    z = [z0]
    for i in 1:steps
        x = a + (i - 1) * h
        k1 = f(x, z[end])
        z1 = z[end] .+ h .* k1
        k2 = f(x + h, z1)
        push!(z, z[end] .+ h / 2 .* (k1 + k2))
    end
    return z
end

function midpoint_method(f, z0, steps, a, b)
    h = (b - a) / steps
    z = [z0]
    for i in 1:steps
        t0 = a + (i - 1) * h
        tm = t0 + h / 2
        zm = z[end] .+ h / 2 .* f(t0, z[end])
        z1 = z[end] .+ h .* f(tm, zm)
        push!(z, z1)
    end
    return z
end

# Apply the methods
y_explicit_euler = explicit_euler(f, z0, steps, 0, T)
y_implicit_euler = implicit_euler(f, z0, steps, 0, T)
y_modified_euler = modified_euler(f, z0, steps, 0, T)
y_midpoint = midpoint_method(f, z0, steps, 0, T)

# Extract θ values for plotting
θ_explicit_euler = [yi[1] for yi in y_explicit_euler]
θ_implicit_euler = [yi[1] for yi in y_implicit_euler]
θ_modified_euler = [yi[1] for yi in y_modified_euler]
θ_midpoint = [yi[1] for yi in y_midpoint]

# Plot the results
plot(t, θ_explicit_euler, label="Explicit Euler", xlabel="Time (s)", ylabel="θ (rad)", legend=:topright)
plot!(t, θ_implicit_euler, label="Implicit Euler")
plot!(t, θ_modified_euler, label="Modified Euler")
plot!(t, θ_midpoint, label="Midpoint Method")

savefig("Euler_Sol.png")