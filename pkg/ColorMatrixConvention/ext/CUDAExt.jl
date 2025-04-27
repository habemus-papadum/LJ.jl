module CUDAExt

import Colors: Colorant
import CUDA: CuMatrix

function Base.show(io::IO, mime::MIME"image/png", img::CuMatrix{C}) where C<:Colorant 
    Base.show(io, mime, Array(img))
end

Base.showable(mime::MIME"image/png", img::CuMatrix{C}) where C<:Colorant = true

end