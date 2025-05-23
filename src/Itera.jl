module Itera

include(joinpath("engine", "tsm", "TreeStateMachine.jl"))

# Core shared
include("engine/common/rng.jl")

# State system
include("engine/service/participant.jl")
include("engine/service/phase.jl")
include("engine/core/state.jl")

# Game services
include("engine/service/effect.jl")
include("engine/service/choice.jl")
include("engine/service/pipeline.jl")

# Snapshot and log
include("engine/common/snapshot.jl")
include("engine/common/tracker.jl")
include("engine/common/logger.jl")

# Execution
include("engine/core/turn.jl")

end # module