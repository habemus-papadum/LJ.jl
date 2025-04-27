module MetalExt

import Colors: Colorant
import Metal: MtlMatrix

function Base.show(io::IO, mime::MIME"image/png", img::MtlMatrix{C}) where C<:Colorant 
    Base.show(io, mime, Array(img))
end

Base.showable(mime::MIME"image/png", img::MtlMatrix{C}) where C<:Colorant = true

end