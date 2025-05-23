module Common
    export RNG, TSM

    include(joinpath("rng", "rng.jl"))
    include(joinpath("tsm", "TreeStateMachine.jl"))

    const TSM = TreeStateMachine
end