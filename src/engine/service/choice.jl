module Choice

export Context, Result, StepResult, strategy_register, step!

using Random: AbstractRNG
using ..TreeCycle
using ..RNG
using ..Effect
using ..State

"""
Context for choice-driven interaction during a turn.

Fields:
- `option_tree`: TreeCycle.Group of selectable elements
- `history`: selected options
- `minimum` / `maximum`: bounds on number of selections
- `state`: game instance
- `rng`: RNG instance
- `on_complete`: optional callback at end of choice loop
- `on_choice_event`: optional event Symbol emitted on selection
"""
mutable struct Context
    option_tree::TreeCycle.Group
    history::Vector
    minimum::Int
    maximum::Int
    state::Game
    rng::AbstractRNG
    on_complete::Union{Nothing, Function}
    on_choice_event::Union{Nothing, Symbol}
    index_start::Int
    is_initial::Bool

    function Context(options::Vector, state::Game, rng::AbstractRNG;
                     minimum::Int = 0, maximum::Int = 1,
                     on_complete = nothing, on_choice_event = nothing)
        @assert 0 <= minimum <= maximum <= length(options) "Invalid selection bounds"
        group = TreeCycle.Group([TreeCycle.Leaf(x) for x in options])
        return new(group, [], minimum, maximum, state, rng,
                   on_complete, on_choice_event,
                   group.index_current, true)
    end
end

"""
Result(selection)

Holds one decision result (or `nothing` if skipped).
"""
struct Result
    selection::Any
end

"""
StepResult(selection, done)

Wraps a `Result` with turn-loop control signal.
"""
struct StepResult
    selection::Any
    done::Bool
end

# Registered STRATEGY_LIST
const _STRATEGY_LIST = Dict{Symbol, Function}()

"""
strategy_register(name, fn)

Registers a strategy for selection, taking (candidate, context) and returning Result.
"""
function strategy_register(name::Symbol, fn::Function)
    _STRATEGY_LIST[name] = fn
end

"""
step!(ctx; strategy=:random)

Performs one selection step using the specified strategy.
Handles event emission, result recording, and loop termination.
"""
function step!(ctx::Context; strategy::Symbol = :random)::StepResult
    @assert haskey(_STRATEGY_LIST, strategy) "Unknown strategy: $strategy"

    candidate = TreeCycle.current_get!(ctx.option_tree)
    result = _STRATEGY_LIST[strategy](candidate, ctx)

    if result.selection !== nothing
        push!(ctx.history, result.selection)
        if ctx.on_choice_event !== nothing
            Effect.event_emit!(ctx.state, ctx.on_choice_event, result.selection)
        end
    end

    TreeCycle.advance!(ctx.option_tree)

    is_looped = (!ctx.is_initial && ctx.option_tree.index_current == ctx.index_start)
    ctx.is_initial = false

    done = length(ctx.history) >= ctx.maximum ||
           (is_looped && length(ctx.history) >= ctx.minimum)

    if done && ctx.on_complete !== nothing
        ctx.on_complete(ctx)
    end

    return StepResult(result.selection, done)
end

# Built-in strategy: :random
strategy_register(:random, (candidate, ctx) -> begin
    count = length(ctx.history)
    if count < ctx.minimum
        Result(candidate)
    elseif count >= ctx.maximum
        Result(nothing)
    else
        rand(ctx.rng, Bool) ? Result(candidate) : Result(nothing)
    end
end)

end # module Choice