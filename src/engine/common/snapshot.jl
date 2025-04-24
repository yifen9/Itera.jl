module Snapshot

export snapshot, save, load, summarize

using JLSO

using ..State

"""
snapshot(state::Game) -> Game

Return a full deep copy of game state.
"""
snapshot(state::Game) = deepcopy(state)

"""
save(state::Game, path::String)

Save a complete snapshot to a file (JLSO format).
"""
function save(state::Game, path::String)
    snap = snapshot(state)
    JLSO.save(path, :state => snap)
end

"""
load(path::String) -> Game

Load a game snapshot from a file.
"""
function load(path::String)::Game
    obj = JLSO.load(path)
    return obj[:state]
end

"""
summarize(state::Game) -> NamedTuple

Return a minimal summary of key state values.
"""
function summarize(state::Game)
    player = try Game.player_current_get(state) catch _ nothing end
    phase  = try Game.phase_current_get(state) catch _ nothing end
    effect = get(state.data, :effect, [])
    return (
        player = player,
        phase  = phase,
        effect_count = length(effect),
    )
end

end # module Snapshot