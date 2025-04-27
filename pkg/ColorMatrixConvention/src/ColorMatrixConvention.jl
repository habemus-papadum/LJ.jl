module ColorMatrixConvention

import FileIO: save, Stream, @format_str
import ImageCore: mapc, clamp01nan
import FixedPointNumbers: N0f8
import Colors: Colorant, Color, AbstractGray, RGB, RGBA

import Deps: @deps
@deps Colors FixedPointNumbers


# Disable svg output from Colors.jl
Base.showable(::MIME"image/svg+xml", img::AbstractMatrix{C}) where {C<:Colorant} = false
Base.showable(::MIME"image/svg+xml", img::AbstractMatrix{C}) where {C<:Color} = false

# lifted from ImageShow
csnormalize(c::AbstractGray) = Gray(c)
csnormalize(c::Color) = RGB(c)
csnormalize(c::Colorant) = RGBA(c)
mapi(x) = mapc(N0f8, clamp01nan(csnormalize(x)))

function Base.show(io::IO, mime::MIME"image/png", img::AbstractMatrix{C}) where C<:Colorant
    save(Stream{format"PNG"}(io), img,  mapi=mapi)
end

# ImageShow and this package have slighlty incompatible definitions of show (not in terms of layout but
# ImageShow has some heuristics about image size).  The last one to load will win, but with compiler warnings

end # module ColorMatrixConvention
