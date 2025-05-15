module State

export Game, from_player_and_action,
       player_current_get, phase_current_get,
       player_advance!, phase_advance!,
       step_resolve!, state_reset!, leaf_collect, update!

using Random: AbstractRNG
using ..Participant
using ..Phase
using ..RNG

mutable struct Game
    player_group::Participant.Group
    phase_group::Phase.Group
    data::Dict{Symbol,Any}
    rng::AbstractRNG
    snapshot_on::Union{Nothing, Function}
    tracker_on::Bool
    logger_on::Bool
end

function Game(; player_group, phase_group, data=Dict(), rng=RNG.default(), snapshot_on=nothing, tracker_on=false, logger_on=false)
    return Game(player_group, phase_group, data, rng, snapshot_on, tracker_on, logger_on)
end

function from_player_and_action(player::Vector, action::Vector;
                                data::Dict{Symbol,Any}=Dict{Symbol,Any}(),
                                rng::AbstractRNG=RNG.default())
    player_group = Participant.Group([Participant.Leaf(p) for p in player])
    phase_group = Phase.Group([Phase.Leaf(a) for a in action])
    return Game(player_group=player_group, phase_group=phase_group, data=data, rng=rng)
end

player_current_get(state::Game) = Participant.current_get(state.player_group)

phase_current_get(state::Game) = Phase.current_get(state.phase_group)

function player_advance!(state::Game)
    Participant.advance!(state.player_group)
    return state
end

function phase_advance!(state::Game)
    Phase.advance!(state.phase_group)
    return state
end

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

function state_reset!(state::Game)
    Participant.reset!(state.player_group)
    Phase.reset!(state.phase_group)
    return state
end

function leaf_collect(node)
    node_list = Any[]
    if node isa Participant.Leaf || node isa Phase.Leaf
        push!(node_list, node)
    elseif node isa Participant.Group || node isa Phase.Group
        for child in node.child_list
            append!(node_list, leaf_collect(child))
        end
    end
    return node_list
end

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

end