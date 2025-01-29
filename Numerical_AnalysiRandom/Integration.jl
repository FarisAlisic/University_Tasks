using Plots

f(x, y) = x^2 + y^2
x_lower_bound = 0
x_upper_bound = 1
y_lower_bound(x) = 0
y_upper_bound(x) = x^2

function integration(f, xlb, xub, ylb, yub; step_size = 0.0001)
    integral = 0
    x = xlb
    while x < xub
        y = y_lower_bound(x)
        while y < y_upper_bound(x)
            mdpt_volume = f(x + 0.5 * step_size, y + 0.5 * step_size) * step_size^2
            f_lower_left = f(x, y)
            f_lower_right = f(x + step_size, y)
            f_upper_left = f(x, y + step_size)
            f_upper_right = f(x + step_size, y + step_size)
            s = f_lower_left + f_lower_right + f_upper_left + f_upper_right
            trap_volume = 0.25 * step_size^2 * s
            integral += (2 * mdpt_volume + trap_volume) / 3.0
            y += step_size
        end
        x += step_size
    end
    println(integral)
end

println("CORRECT \n0.2476190476\n")
integration(f, x_lower_bound, x_upper_bound, y_lower_bound, y_upper_bound)

