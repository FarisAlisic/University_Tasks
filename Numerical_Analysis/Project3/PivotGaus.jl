using LinearAlgebra
using Plots

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

function solve_bvp(a, b, c, f, a0, b0, alpha0, beta0, a_range, N)
    
    h = (b0 - a0) / N
    x = range(a0, stop=b0, length=N+1)
    A = zeros(N+1, N+1)
    B = zeros(N+1)

    for i in 2:N
        ai = a(x[i])
        bi = b(x[i])
        ci = c(x[i])
        
        A[i, i-1] = 1 / h^2 - bi / (2 * h)
        A[i, i] = -2 / h^2 + ci
        A[i, i+1] = 1 / h^2 + bi / (2 * h)
        B[i] = f(x[i])
    end
    
    A[1, 1] = 1.0
    A[N+1, N+1] = 1.0
    B[1] = alpha0
    B[N+1] = beta0
    y = pivotGaussianElimination(A, B)

    plot(x, y, xlabel="x", ylabel="y", title="Solution")
    savefig("Pivot_sol.png")
end

a(x) = 1
b(x) = sin(exp(2*x)*2*x)
c(x) = 4*(exp(x^2)/32)
f(x) = tan(20*x)
a0 = 0.0
b0 = 3.0
alpha0 = 3.68
beta0 = 0.12
a_range = (a0, b0)
N = 100

solve_bvp(a, b, c, f, a0, b0, alpha0, beta0, a_range, N)