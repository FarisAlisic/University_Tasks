function trapezoidal_rule(f, a, b, n)
    h = (b - a) / n
    s = 0.5 * (f(a) + f(b))
    for i in 1:(n-1)
        s += f(a + i*h)
    end
    return s * h
end

function simpsons_3_8_method(f, a, b, n)
    h = (b - a) / (3n)
    s = f(a) + f(b)
    s = s + 3*f(a+h) + 3*f(a+2h)
    for i = 1:n-1
        s = s + 2*f(a+(3*i)*h) + 3*f(a+(3*i+1)*h) + 3*f(a+(3*i+2)*h)
    end
    return (3h / 8) * s
end

function integration(f, xlb, xub, ylb, yub; step_size = 0.001)
    nx = Int(ceil((xub - xlb) / step_size))
    ny = Int(ceil((yub(xub) - ylb(xlb)) / (3 * step_size)))  # Assuming y-range is approximated by xub, update if necessary
    
    integral = 0.0
    
    function inner_integral(x)
        y_lower = ylb(x)
        y_upper = yub(x)
        g(y) = f(x, y)
        h = (y_upper - y_lower) / (3 * ny)
        
        return simpsons_3_8_method(g, y_lower, y_upper, ny)
    end
    integral = simpsons_3_8_method(inner_integral, xlb, xub, nx)
    println(integral)
end

f(x, y) = (x+(2*y))^(-2)
x_lower_bound = 1
x_upper_bound = 7
y_lower_bound(x) = 1
y_upper_bound(x) = 2*x
println("Expected result: \n0.35471512942")

integration(f, x_lower_bound, x_upper_bound, y_lower_bound, y_upper_bound)