module Turn

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