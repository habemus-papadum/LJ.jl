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

# ╔═╡ 6cf03aac-2d27-11f0-3bd2-bf8f7b71ec2a
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
    using CUDA, Colors, ColorMatrixConvention, PlutoUI, PlutoTeachingTools
	using MarkdownLiteral, PlutoImageCoordinatePicker
end

# ╔═╡ 52beaf71-98b0-4977-aff7-18202a48241f
@bind x Slider(100:600, 400, true)

# ╔═╡ 9b9af897-4005-4dfc-bd14-e6fe6ca1c129
begin
	struct Literal{T} end
    Base.:(*)(x, ::Type{Literal{T}}) where {T} = T(x)
    const i32 = Literal{Int32}
end

# ╔═╡ a858012d-8601-4656-ad17-86fb112a3d73
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

# ╔═╡ 43f180af-da3f-43f8-a015-7478d585ab7e
let 
    simple(i,j,r,c) = colorant"thistle"
    
    n = x
    b = CuArray{RGB{Float32}}(undef, n,n)
    generate(simple, b)
    b
end

# ╔═╡ f52eab6f-6bd0-4a51-9383-ddfe8114e5bd


# ╔═╡ 29015af2-fa03-4bb1-82b4-20906a6f6fc0
begin
	const SQRT3_f32 = Float32(sqrt(3.0))          # ≈ 1.7320508f0

	function point_to_cube(px::Float32, py::Float32; size::Float32 = 1f0)
	    # --- scale away hex size -------------------------------------------------
	    px /= size
	    py /= size
	
	    # --- fractional cube coordinates ----------------------------------------
	    zf = (2f0/3f0) * py
	    xf = (SQRT3_f32/3f0) * px - py/3f0
	    yf = -xf - zf          # keep the invariant x+y+z = 0
	
	    # --- round to nearest integer cube --------------------------------------
	    rx, ry, rz = round(Int, xf), round(Int, yf), round(Int, zf)
	    dx, dy, dz = abs(Float32(rx) - xf), abs(Float32(ry) - yf), abs(Float32(rz) - zf)
	
	    if dx > dy && dx > dz
	        rx = -ry - rz
	    elseif dy > dz
	        ry = -rx - rz
	    else
	        rz = -rx - ry
	    end
	    return (rx, ry, rz)
	end
	
	"""
	    local_coords(px, py; size = 1f0) -> ((X,Y,Z), (x′, y′))
	
	Return the containing hex’s cube coords **and**
	the local coordinates of the point after translating that hex so its
	centre sits at the origin.
	"""
	function local_coords(px::Float32, py::Float32; size::Float32 = 1f0)
	    # 1. Which hex are we in?
	    (cx, cy, cz) = point_to_cube(px, py; size)
	
	    # 2. Centre of that hex in world-space
	    centre_x = size * (SQRT3_f32 * Float32(cx) + (SQRT3_f32/2f0) * Float32(cz))
	    centre_y = size * (1.5f0 * Float32(cz))
	
	    # 3. Local offset relative to translated origin-hex
	    local_x = px - centre_x
	    local_y = py - centre_y
	    return ((cx, cy, cz), (local_x, local_y))
	end
end

# ╔═╡ c5be21a6-820c-4a87-b129-63b6a6d3c9aa
shader(i,j, r, c) = begin
	if abs(i - r / 2i32) < 2i32 || abs(j - c / 2i32) < 2i32
		return colorant"white"
	end
	
	y  =  - Float32(i - r / 2i32) / (r/ 2f0) * 10.0f0
	x  =    Float32(j - c / 2i32) / (r/ 2f0) * 10.0f0

	if abs(y - 6) < 0.1
		return colorant"yellow"
	end

	(hii, hjj, hkk), (xx, yy) = local_coords(x, y, size = 2.0f0)
	deg = atand(yy, xx)
	if -30.0f0 <= deg < 30.0f0
		return colorant"navy"
	end
	return RGB{Float32}(0.5f0 + hii/20.0f0, 
						0.5f0 + hjj/20.0f0, 
						0.5f0 +hkk/20.0f0)

end

# ╔═╡ 4385af19-011a-4640-8c6f-08f5fb173241
let 
    b = CuArray{RGB{Float32}}(undef, x,x)
    generate(shader, b)
    aside(md"""
	## Result
	$(b)
	""")
end

# ╔═╡ 759aa18d-954c-49d4-bfda-f28da08e4894
let 
    simple(i,j,r,c) = colorant"thistle"
    
    n = x
    b = CuArray{RGB{Float32}}(undef, n,n)
    generate(simple, b)
    b
	io = IOBuffer()
	Base.show(io, MIME("image/png"), b)
	bt = take!(io)
	@bind coord ImageCoordinatePicker(bt, pointer_url=PlutoImageCoordinatePicker.Pointers.CrossInverted)
end

# ╔═╡ 525be509-1866-482b-bb0b-94181494494e
coord

# ╔═╡ Cell order:
# ╠═6cf03aac-2d27-11f0-3bd2-bf8f7b71ec2a
# ╠═a858012d-8601-4656-ad17-86fb112a3d73
# ╠═52beaf71-98b0-4977-aff7-18202a48241f
# ╠═43f180af-da3f-43f8-a015-7478d585ab7e
# ╠═9b9af897-4005-4dfc-bd14-e6fe6ca1c129
# ╟─4385af19-011a-4640-8c6f-08f5fb173241
# ╠═c5be21a6-820c-4a87-b129-63b6a6d3c9aa
