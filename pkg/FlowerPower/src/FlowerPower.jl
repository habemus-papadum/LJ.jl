module FlowerPower

🌺 = f -> (args...; kwargs...) -> x -> f(x, args...; kwargs...)

macro 🌺(placeholder, f)
    esc(:($placeholder -> $f))
end

macro 🌺(f)
    esc(:(@🌺(🐞, $f)))
end

export 🌺, @🌺


# e.g. 
#  x |> @🌺 g(🐞, d, t)    |> 
#       @🌺 h(1, d, n=🐞)  |>
#       f                  |>
#       @🌺 q(1, 🐞, 3) 

end


 