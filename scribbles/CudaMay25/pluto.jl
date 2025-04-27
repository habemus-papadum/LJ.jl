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
@bind x Slider(50:100)

# ╔═╡ 04f0e217-2498-40c8-8f6a-93f7d71613f0


# ╔═╡ e4f0003f-b72e-4307-aef9-ccd60b177073
let 
    simple(i,j,r,c) = colorant"thistle"
    
    n = x
    b = CuArray{RGB{Float32}}(undef, n,n)
    generate(simple, b)
    b
end

# ╔═╡ Cell order:
# ╠═643c8fe6-23bf-11f0-3e1d-25bc6b806e2e
# ╠═8db812b4-820a-4291-b8c0-b3dc29b526df
# ╠═4aacf788-6536-4c4b-a8e3-774e16ed2a12
# ╠═04f0e217-2498-40c8-8f6a-93f7d71613f0
# ╠═e4f0003f-b72e-4307-aef9-ccd60b177073
