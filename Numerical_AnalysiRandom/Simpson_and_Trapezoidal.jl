function simpson(f, a, b, N)
    delta = (b - a) / (3 * N)
    total = f(a) + f(b)
    total += 3 * (f(a + delta) + f(a + 2 * delta))
    
    for k = 1:(N-1)
        x1 = a + (3 * k + 1) * delta
        x2 = a + (3 * k + 2) * delta
        x3 = a + 3 * k * delta
        
        total += 3 * (f(x1) + f(x2)) + 2 * f(x3)
    end
    
    return (3 * delta / 8) * total
end

function doubleSimp(f, x0, x1, y0, y1, N)
    function computeYIntegral(x)
        local fy
        function fy(y)
            return f(x, y)
        end
        return simpson(fy, y0(x), y1(x), N)
    end
    finalIntegral = simpson(computeYIntegral, x0, x1, N)
    return finalIntegral
end

function trapezoidal(f, a, b, N)
    step = (b - a) / N
    sum = 0.5 * (f(a) + f(b))

    for k = 1:(N-1)
        sum += f(a + k * step)
    end
    return sum * step
end

function doubleTrap(f, x0, x1, y0, y1, N)
    function computeYIntegral(x)
        function innerFunction(y)
            return f(x, y)
        end
        return trapezoidal(innerFunction, y0(x), y1(x), N)
    end
    finalIntegral = trapezoidal(computeYIntegral, x0, x1, N)
    return finalIntegral
end

#   First Example

f(x, y) = x^2 + y^2
x_lower_bound = 0
x_upper_bound = 1
y_lower_bound(x) = 0
y_upper_bound(x) = x^2
println("First Example!\n\nExpected result: \n0.2476190476")

solutionSimp = doubleSimp(f, x_lower_bound, x_upper_bound, y_lower_bound, y_upper_bound, 1000)
solutionTrap = doubleTrap(f, x_lower_bound, x_upper_bound, y_lower_bound, y_upper_bound, 1000)
println("Simpson solution 3/8 is: \n", solutionSimp)
println("Trap solution is: \n", solutionTrap)

#   Second Example

f(x, y) = (x+(2*y))^(-2)
x_lower_bound = 1
x_upper_bound = 7
y_lower_bound(x) = 1
y_upper_bound(x) = 2*x
println("\n\n\nSecond Example!\n\nExpected result: \n0.35471512942")

solutionSimp = doubleSimp(f, x_lower_bound, x_upper_bound, y_lower_bound, y_upper_bound, 1000)
solutionTrap = doubleTrap(f, x_lower_bound, x_upper_bound, y_lower_bound, y_upper_bound, 1000)
println("Simpson solution 3/8 is: \n", solutionSimp)
println("Trap solution is: \n", solutionTrap)