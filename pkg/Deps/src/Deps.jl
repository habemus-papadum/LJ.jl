"""
Provide easy access to a package's 3rd party dependencies.

The following usage by the author(s) of `Lib`:
```
module Lib
... 

import Deps: @deps
@deps Colors StaticArrays

end
```

provides the following end user experience
```
using Lib.Deps
# now we have Colors.RGBA etc
```

or to further streamline 

```
using Lib.Deps
using .Colors
```

or, for quick hacking without concerns of bloating the namespace
`using Lib.Convenience` which is equivalent to `using Colors StaticArrays` 

Note:
`@deps` only modifies the namespace of `Lib` by adding two modules `Lib.Deps` and `Lib.Convenience`.
It is left to the `Lib`'s author(s) to decide what `import`s, `export`'s and `use`s they 
prefer to adopt in `Lib`

Rationale:
--------------
Some libraries expect users to invoke their functions with types from 3rd party libraries.  
A user of such a library, e.g. `Lib`, would need to `Pkg.add` these dependencies prior to use of `Lib``.  
This makes, for instance, copy and pasting sample code from an example file tedious during initial
exploration of `Lib`

TLDR: We are trying avoid a bunch of `Pkg` errors on first invocation.

`Deps.jl` allows `Lib` to provide convenience accessors to these dependencies to expedite certain 
use cases. 
(typically an end application, a library that uses Lib as an  entirely internal dependency, 
or hacking/exploration)

"""

module Deps
import Reexport

macro deps(pkgs...)
    quote
        @eval module Convenience
            using Deps.Reexport
            $([:(@reexport using $p) for p in pkgs]... )
        end

        @eval module Deps
        $([:(using  $p) for p in pkgs]... )
        $([:(export $p) for p in pkgs]... )
        end
    end
end


end # module Deps
