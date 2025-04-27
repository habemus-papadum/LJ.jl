A Matrix of Colors is easy to generate in Julia: `[RGB(0.5, 1.0, 0.0) for i=1:5, j = 1:5]`.  

But how should we interpret the Matrix when rendering to a 2D surface?

That is, suppose we have:
```
img : AbstractMatrix{C<:Colorant}
m,n = size(img)
```

The questions we are left with are:
- Is `img` a collection of pixels organized in rows and columns?
- Is `img` an image with width and height 
- Also, where is the pixel at `1,1` (bottom or top right)?

This package picks a convention.  Before explaining the choice, let's remember a few English speaking and coding conventions:
- if I have two parameters 'r' and 'c' (e.g. for a function or in a struct), rows always come before columns
  - i.e. it should always be `r, c = m, n` and never `c, r = m, n`
  - columns always increase towards the right of the page (think excel)
  - rows mostly increase towards the bottom of the page (think excel)
    - it is not natural to think of rows increasing as we go up the page, but not impossible 
        - Why? Because from math we associate `y` with the vertical
      page-direction, and in math, y increases towards the top of the page, and rows are also a vertical concept and so somewhat like y
- Similarly, width always comes before height, `w,h = m,n`
  - `w` increases to the right
  - `h` should probably increase towards the top of the page

Those are the choices, the `ColorMatrixConvention` chooses:

```
    # img is meant to displayed with the following coordinate system:
    ## Display coordinate system
    ##  1,1 ---J---->
    ##  |
    ##  I
    ##  |
    ##  v
 ```

This convention is chosen because: 
 - windows are usually manipulated by their lower right corner [THIS IS THE MAIN POINT]
 - This convention keeps the image from jumping after a window resize
 
- FileIO.save() uses this convention
- opengl textures will require flips, which can be achieved in texture coordinates 
