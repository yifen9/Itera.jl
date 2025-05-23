module Engine
    export Common, Core

    include(joinpath("common", "common.jl"))
    include(joinpath("core",   "core.jl"))
end