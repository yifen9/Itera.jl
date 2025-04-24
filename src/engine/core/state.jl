module State

export Game, from_player_and_action,
       player_current_get, phase_current_get,
       player_advance!, phase_advance!,
       step_resolve!, state_reset!, leaf_collect, update!

using Random: AbstractRNG
using ..Participant
using ..Phase
using ..RNG

"""
`Game` holds the game state:
- `player_group`: recursive player/team tree
- `phase_group`: recursive phase/subphase tree
- `data`: `Dict{Symbol,Any}` for plugin extensions
- `rng`: RNG instance
"""
mutable struct Game
    player_group::Participant.Group
    phase_group::Phase.Group
    data::Dict{Symbol,Any}
    rng::AbstractRNG
    snapshot_on::Union{Nothing, Function}
    tracker_on::Bool
    logger_on::Bool
end

"""
Game(; player_group, phase_group, data=Dict{Symbol,Any}(), rng=RNG.default()) -> Game

Construct a new game state with given player and phase trees.
Throws `ArgumentError` if trees have no leaves.
"""
function Game(; player_group, phase_group, data=Dict(), rng=RNG.default(), snapshot_on=nothing, tracker_on=false, logger_on=false)
    return Game(player_group, phase_group, data, rng, snapshot_on, tracker_on, logger_on)
end

"""
from_player_and_action(player::Vector, action::Vector;
                       data=Dict{Symbol,Any}(), rng=RNG.default()) -> Game

Helper to create a Game from flat lists of player values and phase actions.
"""
function from_player_and_action(player::Vector, action::Vector;
                                data::Dict{Symbol,Any}=Dict{Symbol,Any}(),
                                rng::AbstractRNG=RNG.default())
    player_group = Participant.Group([Participant.Leaf(p) for p in player])
    phase_group = Phase.Group([Phase.Leaf(a) for a in action])
    return Game(player_group=player_group, phase_group=phase_group, data=data, rng=rng)
end

"""
player_current_get(state::Game) -> Any

Return the active player from the player_group tree.
"""
player_current_get(state::Game) = Participant.current_get!(state.player_group)

"""
phase_current_get(state::Game) -> Function

Return the active phase action from the phase_group tree.
"""
phase_current_get(state::Game) = Phase.current_get!(state.phase_group)

"""
player_advance!(state::Game) -> Game

Advance the player_group tree in-place.
"""
function player_advance!(state::Game)
    Participant.advance!(state.player_group)
    return state
end

"""
phase_advance!(state::Game) -> Game

Advance the phase_group tree in-place.
"""
function phase_advance!(state::Game)
    Phase.advance!(state.phase_group)
    return state
end

"""
step_resolve!(state::Game; order::Symbol=:phase_first) -> Game

Execute one step:
- `:phase_first`: run phase action, advance phase, advance player
- `:player_first`: advance player, run phase action, advance phase
Phase action must accept `(state, rng)`.
"""
function step_resolve!(state::Game; order::Symbol=:phase_first)
    if order == :phase_first
        action = phase_current_get(state)
        action(state, state.rng)
        phase_advance!(state)
        player_advance!(state)
    elseif order == :player_first
        player_advance!(state)
        action = phase_current_get(state)
        action(state, state.rng)
        phase_advance!(state)
    else
        throw(ArgumentError("Unknown step_resolve! order: $order"))
    end
    return state
end

"""
state_reset!(state::Game) -> Game

Reset both player_group and phase_group to initial state.
"""
function state_reset!(state::Game)
    Participant.reset!(state.player_group)
    Phase.reset!(state.phase_group)
    return state
end

"""
leaf_collect(node) -> Vector{Node}

Recursively collect all leaf nodes from a tree.
"""
function leaf_collect(node)
    node_list = Any[]
    if node isa Participant.Leaf || node isa Phase.Leaf
        push!(node_list, node)
    elseif node isa Participant.Group || node isa Phase.Group
        for child in node.member_list
            append!(node_list, leaf_collect(child))
        end
    end
    return node_list
end

"""
update!(state::Game) -> Game

Invoke registered update hooks (tracker, logger, snapshot).
"""
function update!(state::Game)
    if state.tracker_on
        Tracker.track!(state)
    end
    if state.logger_on
        Logger.log!(:update; tag=:auto, message="Game updated.")
    end
    if state.snapshot_on !== nothing
        state.snapshot_on(state)
    end
    return state
end

end # module State