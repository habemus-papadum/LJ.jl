### A Pluto.jl notebook ###
# v0.20.6

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 643c8fe6-23bf-11f0-3e1d-25bc6b806e2e
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
    using CUDA, Colors, ColorMatrixConvention, PlutoUI
end

# ╔═╡ 04f0e217-2498-40c8-8f6a-93f7d71613f0


# ╔═╡ 1a871075-c738-495b-9fe1-14b9d91b88e8
@bind hue Slider(0:360, 7, true)

# ╔═╡ e865478b-7892-40a8-87b0-a7fe64adc5cc
begin
	struct Literal{T} end
    Base.:(*)(x, ::Type{Literal{T}}) where {T} = T(x)
    const i32 = Literal{Int32}
end

# ╔═╡ 8db812b4-820a-4291-b8c0-b3dc29b526df
begin
	function generate_kernel(f, img)
		r, c = Int32.(size(img))
		i = threadIdx().x + (blockIdx().x - 1) * blockDim().x
		j = threadIdx().y + (blockIdx().y - 1) * blockDim().y
		
		@inbounds if i <= r && j <= c
			@inline img[i,j] = eltype(img)(f(i,j,r,c))
		end
		return
	end
	
	function generate(f, img::CuArray{C}, sync=true) where C<:Colorant
		threads = 16,16
		blocks = cld.(size(img), threads)
			@cuda threads=threads blocks=blocks generate_kernel(f, img)
			if sync
				CUDA.synchronize()
			end
		img
	end

end

# ╔═╡ 4aacf788-6536-4c4b-a8e3-774e16ed2a12
begin 
@bind x Slider(100:600, 400, true)
end

# ╔═╡ e4f0003f-b72e-4307-aef9-ccd60b177073
let 
    simple(i,j,r,c) = colorant"thistle"
    
    n = x
    b = CuArray{RGB{Float32}}(undef, n,n)
    generate(simple, b)
    b
end

# ╔═╡ 08e8c8b9-a79e-40d7-af1c-1fc84b456817
let 
	function sweep(hue) 
	    hr = deg2rad(hue) 
	    c  = cos(hr)
	    s  = sin(hr)
	    (i,j,w,h) -> RGB{Float32}(Lab(100*i/w, 100*j/h*c, 100*j/h*s))
	end
    n = x
    b = CuArray{RGB{Float32}}(undef, n,n)
    generate(sweep(hue), b)
    b
end
    

# ╔═╡ 3870a643-1b43-492b-9ba3-7d8eeaeca42a
@bind rad Slider(0.1f0:0.1f0:2.0f0, 1.7f0, true)	


# ╔═╡ 13a58ea5-e23d-4a65-b7e2-b57dfad504d8
begin
const _rad = rad
shader(i,j, r, c) = begin
        i, ii = divrem(i, 100i32)
        j, jj = divrem(j, 100i32)
        if i == 1 && j == 2 && (ii < 3 || jj < 3 || ii > 97 || jj > 97)
            return colorant"white" 
        end

        x  =  Float32(ii - 50i32) / 50.0f0
        y  =  Float32(jj - 50i32) / 50.0f0
        x = Float32(abs(x))
        y = Float32(abs(y))
        if x  + y - _rad < 0.0f0
        	if max(x,y) > 0.98f0
                return colorant"black"
            else
                return colorant"salmon"
            end
        else 
        	return colorant"steelblue"
        end
end
end

# ╔═╡ eb07dfb9-c511-4132-8caa-b1c6800f8c7b
let 
    b = CuArray{RGB{Float32}}(undef, x,x)
    generate(shader, b)
    b
end

# ╔═╡ Cell order:
# ╠═643c8fe6-23bf-11f0-3e1d-25bc6b806e2e
# ╠═8db812b4-820a-4291-b8c0-b3dc29b526df
# ╠═04f0e217-2498-40c8-8f6a-93f7d71613f0
# ╠═e4f0003f-b72e-4307-aef9-ccd60b177073
# ╠═1a871075-c738-495b-9fe1-14b9d91b88e8
# ╠═08e8c8b9-a79e-40d7-af1c-1fc84b456817
# ╠═e865478b-7892-40a8-87b0-a7fe64adc5cc
# ╠═4aacf788-6536-4c4b-a8e3-774e16ed2a12
# ╠═eb07dfb9-c511-4132-8caa-b1c6800f8c7b
# ╠═13a58ea5-e23d-4a65-b7e2-b57dfad504d8
# ╠═3870a643-1b43-492b-9ba3-7d8eeaeca42a
