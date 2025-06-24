using ImageShow, Metal, Colors, GeometryBasics, StaticArrays


# UI
function Base.show(io::IO, mime::MIME"image/png", img::MtlArray{C}) where C<:Colorant 
    Base.show(io, mime, Array(img))
end

function Base.showable(mime::MIME"image/png", img::MtlArray{C}) where C<:Colorant 
    true
end


# Our basic primitive
function generate(f, img)
    r, c = Int32.(size(img))
    i,j = thread_position_in_grid_2d()
    
    @inbounds if i <= r && j <= c
        @inline img[i,j] = eltype(img)(f(i,j,r,c))
    end
    return
end


simple(i,j,r,c) = colorant"thistle"
simple2(i,j,r,c) = RGB{Float32}(0.84705883, 0.7490196, 0.84705883)
try
    n = 50
    b = MtlArray{RGB{Float32}}(undef, n,n)
    threads = 16
    groups = cld.(n, threads)
    @Metal.sync @metal threads=threads,threads groups=groups,groups generate(simple, b)
    b
catch err
    print(code_typed(err))
    raise(err)
end