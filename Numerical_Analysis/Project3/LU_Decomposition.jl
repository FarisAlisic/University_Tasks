using LinearAlgebra
using Plots

function LU_decomposition(A, b)
    n = size(A, 1) # calculation of square matrix
    L = zeros(n, n) # initialization of empty matrix, will store LT part of LU decomposition
    U = copy(A) # UT part of LU decomposition
    P = Matrix(I, n, n) # permutation matrix to keep track of row interchanges and for better stability
     
    for k in 1:n-1
        val, index = findmax(abs.(U[k:n, k])) # finds the index of MAX absolute value in given submatrix; used for partial pivoting
        index += k - 1 # we need to make it relative to original matrix, not submatrix
     
        if val == 0 # if MAX absolute value is zero
            error("Division by 0!")
        end
       
        # partial pivoting, element with the largest absolute value is placed at diagonal for stability; swaping rows 'k' and 'index' between 'U', 'L' and 'P'
        U[[k, index], :] = U[[index, k], :]
        L[[k, index], :] = L[[index, k], :]
        P[[k, index], :] = P[[index, k], :]
     
        for i in k+1:n
            L[i, k] = U[i, k] / U[k, k] # calculating to eliminate entries below diagonal
            for j in k+1:n
                U[i, j] -= L[i, k] * U[k, j] # eliminates the entries below diagonal in column 'k' of 'U'
            end
        end
    end
     
    for i in 1:n
        L[i, i] = 1.0 # set diagonal entries to 1
    end
     
    # apply permutation to b
    b = P * b
    n = length(b) # length of vector b
    y = zeros(n)
    x = zeros(n)
     
    # forward substitution: Ly = b
    for i in 1:n # itterating over each eq in system
        y[i] = b[i] # from each eq y, to correspond b
        for j in 1:i-1
            y[i] -= L[i, j] * y[j] # updating 'y[i]', subtracting product of correspond element from 'L' and previously calculated value 'y[j]'
        end
        y[i] = y[i] / L[i, i]
    end
     
    # backward substitution: Ux = y
    for i in n:-1:1 # in reverse order from last eq
        x[i] = y[i]
        for j in i+1:n # iterates over elements of 'x'
            x[i] -= U[i, j] * x[j] # updaitng 'x[i]', similarly like in forward substitution
        end
        x[i] = x[i] / U[i, i] # dividing by diagonal of 'U' at '[i,i]'
    end
     
    return x
end

function differential_eq(a::Function, b::Function, c::Function, f::Function, a0::Float64, b0::Float64, alpha0::Float64, beta0::Float64, a_range::Tuple{Float64, Float64}, N::Int)
    # Define step size
    h = (b0 - a0) / N
    
    # Define grid points
    x = range(a0, stop=b0, length=N+1)
    
    # Initialize matrix and vector for finite difference method, Ax=b
    A_mat = zeros(N+1, N+1)
    B_vec = zeros(N+1)
    
    # Fill matrix and vector
    for i in 2:N
        # Evaluate coefficients at each grid point
        a_i = a(x[i])
        b_i = b(x[i])
        c_i = c(x[i])
        
        # Fill the matrix A and vector B using central difference approximations
        A_mat[i, i-1] = 1 / h^2 - b_i / (2 * h)
        A_mat[i, i] = -2 / h^2 + c_i
        A_mat[i, i+1] = 1 / h^2 + b_i / (2 * h)
        B_vec[i] = f(x[i])
    end
    
    # Apply boundary conditions
    A_mat[1, 1] = 1.0
    A_mat[N+1, N+1] = 1.0
    B_vec[1] = alpha0
    B_vec[N+1] = beta0
    
    # Solve the linear system using LU decomposition
    y = LU_decomposition(A_mat, B_vec)
    
    return x, y
end

a(x) = 1
b(x) = sin(x)
c(x) = exp(x)
f(x) = sin(x)
a0 = 0.0
b0 = 1.0
alpha0 = 0.0
beta0 = 1.0
a_range = (a0, b0)
N = 100

x, y = differential_eq(a, b, c, f, a0, b0, alpha0, beta0, a_range, N)

# Print the solution
println("Solution for the differential equation:")
for i in 1:length(x)
    println("x = ", x[i], ", y = ", y[i])
end

# Plot the solution
plot(x, y, label="Numerical Solution", xlabel="x", ylabel="y", title="Numerical Solution of Second Order BVP")
savefig("LU_sol.png")
