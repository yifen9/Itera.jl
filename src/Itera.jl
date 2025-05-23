module Itera

export Engine

include(joinpath("engine", "engine.jl"))

# include(joinpath("engine", "service", "participant.jl"))
# include(joinpath("engine", "service", "phase.jl"))

# include("engine/core/state.jl")

# Game services
# include("engine/service/effect.jl")
# include("engine/service/choice.jl")
# include("engine/service/pipeline.jl")

# Snapshot and log
# include("engine/common/snapshot.jl")
# include("engine/common/tracker.jl")
# include("engine/common/logger.jl")

# Execution
# include("engine/core/turn.jl")

end