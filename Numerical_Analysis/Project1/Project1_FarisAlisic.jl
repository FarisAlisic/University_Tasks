using LinearAlgebra
using Plots

N = 200
deltaT = 10 / N
alfa = 10
k = m = 1
l0 = sqrt(2)
xd = Float64[0, 2]
a = Float64[0, 1]
x0, v0, lambdaN, mjuN = Float64[1, 1],  Float64[0, 0],  Float64[0, 0],  Float64[0, 0]

function li(xi, ui)
    norm(xi - [ui,0], 2)
end

function F(X)
    N = (length(X) - 1) ÷ 9

    result = Float64[]
    
    x = reshape(X[1:2N], 2, N)
    v = reshape(X[2N + 1:4N], 2, N)
    lambda = reshape(X[4N + 1:6N], 2, N)
    mju = reshape(X[6N + 1:8N], 2, N)
    u = X[8N + 1:9N + 1]

    #   1st eq. bounds

    rspecial = (lambda[:, 2] - lambda[:, 1]) / deltaT + mju[:, 2]
    push!(result, rspecial[1])
    push!(result, rspecial[2])

    rspecial = (lambdaN - lambda[:, N]) / deltaT + mjuN
    push!(result, rspecial[1])
    push!(result, rspecial[2])
    
    #   2nd eq. bounds

    rspecial = ((mju[:, 2] - mju[:, 1]) / deltaT) - (x0 - xd) - ((k * l0 * (x0 - 
            [u[1], 0]) * (x0 - [u[1], 0])' / (m * (li(x0, u[1]))^3)) + (k/m * 
            ((li(x0, u[1])) - l0) / (li(x0, u[1])) * [1 0; 0 1])) * lambda[:, 2]
    push!(result, rspecial[1])
    push!(result, rspecial[2])

    rspecial = ((mjuN - mju[:, N]) / deltaT) - (x[:, N-1] - xd) - ((k * l0 * (x[:, N-1] - 
            [u[N], 0]) * (x[:, N-1] - [u[N], 0])' / (m * (li(x[:, N-1], u[N]))^3)) + (k/m * 
            ((li(x[:, N-1], u[N])) - l0) / (li(x[:, N-1], u[N])) * [1 0; 0 1])) * lambdaN
    push!(result, rspecial[1])
    push!(result, rspecial[2])
    
    #   3rd eq. bounds

    rspecial = ((v[:, 1] - v0) / deltaT) + (k * ((li(x0, u[1])) - l0) * 
            (x0 - [u[1], 0]) / (m * (li(x0, u[1])))) - (a / m)
    push!(result, rspecial[1])
    push!(result, rspecial[2])

    rspecial = ((v[:, N] - v[:, N-1]) / deltaT) + (k * (li(x[:, N-1], u[N]) - l0) * 
            (x[:, N-1] - [u[N], 0]) / (m * li(x[:, N-1], u[N]))) - (a / m)
    push!(result, rspecial[1])
    push!(result, rspecial[2])

    #   4th eq. bounds

    rspecial = ((x[:, 1] - x0) / deltaT) - v0
    push!(result, rspecial[1])
    push!(result, rspecial[2])

    rspecial = ((x[:, N] - x[:, N-1]) / deltaT) - v[:, N-1]
    push!(result, rspecial[1])
    push!(result, rspecial[2])

    #   Iteration for inside points of equations to N-1

    for i ∈ 1:N-2
        local r = (lambda[:, i+2] - lambda[:, i+1]) / deltaT + mju[:, i+2]
        push!(result, r[1])
        push!(result, r[2])

        r = ((mju[:, i+2] - mju[:, i+1]) / deltaT) - (x[:, i] - xd) - ((k * l0 * 
            (x[:, i] - [u[i+1], 0]) * (x[:, i] - [u[i+1], 0])' / (m * 
            ((li(x[:, i], u[i+1]))^3))) + k/m * (li(x[:, i], u[i+1]) - l0) /
            li(x[:, i], u[i+1]) * [1 0; 0 1]) * lambda[:, i+2]
        push!(result, r[1])
        push!(result, r[2])

        r = ((v[:, i+1] - v[:, i]) / deltaT) + (k * ((li(x[:, i], u[i+1])) - l0) * 
            (x[:, i] - [u[i+1], 0]) / (m * (li(x[:, i], u[i+1])))) - (a / m)
        push!(result, r[1])
        push!(result, r[2])

        r = ((x[:, i+1] - x[:, i]) / deltaT) - v[:, i]
        push!(result, r[1])
        push!(result, r[2])
    end

    #   5th eq.
    
    rspecial = (alfa*u[1]) + lambda[:, 1]' * (((-k * l0 * [1 0] * (x0 - 
            [u[1], 0]) / (m * (li(x0, u[1]))^3))[1] * (x0 - [u[1], 0])) + 
            (-k / m * ((li(x0, u[1])) - l0) / (li(x0, u[1])) * [1, 0]))
    push!(result, rspecial)

    for i ∈ 1:N-1
        r = (alfa*u[i+1]) + lambda[:, i+1]' * (((-k * l0 * [1 0] * (x[:, i] - 
            [u[i+1], 0]) / (m * li(x[:, i], u[i+1])^3))[1] * (x[:, i] - [u[i+1], 0])) + 
            (-k / m * (li(x[:, i], u[i+1]) - l0) / li(x[:, i], u[i+1]) * [1, 0]))
        push!(result, r)
    end
    
    rspecial = (alfa*u[N + 1]) + lambdaN' * (((-k * l0 * [1 0] * (x[:, N] - [u[N + 1], 0]) / (m * (li(x[:, N], u[N + 1]))^3))[1] * (x[:, N] - [u[N + 1], 0])) + (-k / m * ((li(x[:, N], u[N + 1])) - l0) / (li(x[:, N], u[N + 1])) * [1, 0]))
    push!(result, rspecial)
    return result
end

function Jacobian(F, X; t = 1e-6)
    N = length(X)
    J = zeros(N, N)
    for i ∈ 1:N
        x = copy(X)
        x[i] += t
        J[:,i] = (F(x) - F(X)) / t
    end
    return J
end

function pivotGaussianElimination(A, b)
    n = size(A, 1)
    Ab = [A b]
    for i in 1:n
        maxIndex = argmax(abs.(Ab[i:end, i]))[1] + i - 1
        Ab[i, :], Ab[maxIndex, :] = Ab[maxIndex, :], Ab[i, :]  
        for j in i+1:n
            d = Ab[j, i] / Ab[i, i]
            Ab[j, i:end] .-= d * Ab[i, i:end]
        end
    end
    x = zeros(n)
    for i in n:-1:1
        x[i] = (Ab[i, end] - dot(Ab[i, i+1:end-1], x[i+1:end])) / Ab[i, i]
    end
    return x
end

function NewtonMethod(F, x0; maxIter=200, tol=1e-6)
    for iter in 1:maxIter
        J = Jacobian(F, x0)
        x1 = pivotGaussianElimination(J, -F(x0))
        x0 .+= x1
        println(iter)
        if norm(x1) < tol
            return x0
        end
    end
    error("Maximum number of iterations reached.")
    return 0
end

t = LinRange(0, 10, 9*N + 1)

result = NewtonMethod(F, rand(Float64, 9 * N + 1); tol=1e-10)
u = result[8N + 1:end]
x = LinRange(0, 10, length(u));
scatter(x, u, label = "u(t)", color = :blue, markersize = 5, 
    markerstrokecolor = :black, markerstrokewidth = 1, line = (2, :black), 
    xlabel = "t", ylabel = "u(t)", legend = :bottomright, title = "N = 200, alfa = 10")
savefig("N200alfa10.png")