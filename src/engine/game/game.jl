module Game

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

export execute!

using ..Choice
using ..Effect
using ..Participant
using ..Phase
using ..Pipeline
using ..State

"""
_effect_apply_and_emit!(state, stepname)

Apply persistent effects and emit event after a step has been executed.
"""
function _effect_apply_and_emit!(state::Game, stepname::Symbol)
    Effect.event_emit!(state, Symbol("on_", stepname))  # emit first
    Effect.apply!(state)                                # then apply persistent effects
end

"""
`execute!(state::Game, action_list::Vector{Pipeline.Step};
          minimum::Int=0, maximum::Int=1, strategy::Symbol=:random) -> Game`

Execute one full turn for the current player:
1. Apply pre-turn persistent effects
2. Select and execute a sequence of steps with repetition bounds
3. Apply post-turn persistent effects
4. Advance both phase and player cycles
5. Trigger unified update hook
"""
function execute!(
    state::Game,
    action_list::Vector{Pipeline.Step};
    minimum::Int = 0,
    maximum::Int = 1,
    strategy::Symbol = :random,
)
    # --- Phase logic ---
    State.phase_current_get(state)(state, state.rng)

    # --- Pre-turn effects ---
    Effect.apply!(state)

    # --- Action selection and execution ---
    ctx = Choice.Context(action_list, state, state.rng;
                         minimum = minimum,
                         maximum = maximum,
                         on_choice_event = :on_action_chosen)

    while true
        result = Choice.step!(ctx; strategy = strategy)
        if result.selection !== nothing
            Pipeline.step_execute!(result.selection, state, state.rng)
            _effect_apply_and_emit!(state, result.selection.name)
        end
        result.done && break
    end

    # --- Post-turn effects ---
    Effect.apply!(state)

    # --- Turn bookkeeping ---
    Phase.advance!(state.phase_group)
    Participant.advance!(state.player_group)
    State.update!(state)

    return state
end

end # module Turn