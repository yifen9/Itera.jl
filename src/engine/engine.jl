module Engine
    export Common, State, Service, Game

    include(joinpath("common",  "common.jl"))
    include(joinpath("state",   "state.jl"))
    # include(joinpath("service", "service.jl"))
    # include(joinpath("game",    "game.jl"))
end