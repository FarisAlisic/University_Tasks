using LinearAlgebra
function gauss_elimination(A, b)
    n = size(A, 1)
   
    # Augmenting the matrix A with vector b
    Ab = [A b]
   
    # Forward Elimination
    for i in 1:n
        # Partial Pivoting
        max_row = i
        for k in i+1:n
            if abs(Ab[k, i]) > abs(Ab[max_row, i])
                max_row = k
            end
        end
        Ab[i, :], Ab[max_row, :] = Ab[max_row, :], Ab[i, :]
       
        # Elimination
        for j in i+1:n
            factor = Ab[j, i] / Ab[i, i]
            Ab[j, i:end] -= factor * Ab[i, i:end]
        end
    end
   
    # Back Substitution
    x = zeros(n)
    for i in n:-1:1
        x[i] = (Ab[i, end] - dot(Ab[i, i+1:end-1], x[i+1:end])) / Ab[i, i]
    end
   
    return x
end
 
# Define the coefficients matrix A and the constants vector b
A =[11.25 6 -10 -1;
    -10 0 18.5 -7.5;
    0 -1 -7.5 8.5;
    -1 1 0.4 0]
b = [0;0;-20;0]
 
# Solve the system using Gaussian elimination
x = gauss_elimination(A, b)
println("Solution: Nodes = ", x)
 