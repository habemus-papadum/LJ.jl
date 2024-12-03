FlowerPower.jl
----------------
Functional Flower Power!
Because Computer Science needs more flowers.

A minimalist, good-enough-for-me, but YMMV, (argument) threading library. 

```
x |> @🌺 g(🐞, d, t)    # g(x, d, t) 
  |> @🌺 h(1, d, n=🐞)  
  |> f                  
  |> @🌺 q(1, 🐞, 3) 
```

🐞 marks the spot.


But feel free to choose your own marker: 
```
  # I 💘 🐘
  x |> @🌺 🐘 w(1, 🐘, 3) 
```

If you only thread into the first argument, then, there is a functional variant:

```
x |> 🌺(g)(1,2)          # g(x,1,2)
  |> 🌺(h)(bar=true)
  |> @🌺 h(1, d, n=🐞)  
  |> f                  
  |> @🌺 q(1, 🐞, 3)
  |> etc
```

