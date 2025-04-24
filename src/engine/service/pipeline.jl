module Pipeline

export Step, Flow, step_execute!, flow_execute!, step_current_name

using Random: AbstractRNG

using ..Effect
using ..State
using ..TreeCycle

"""
`Step` represents a single unit of execution in a game pipeline.

# Fields
- `name::Symbol`: Identifier of the step.
- `operation::Function`: Executable function `(state, rng, args...) -> Any`.
- `condition::Function`: Predicate `(state) -> Bool`, determines if step runs.
- `repetition::Union{Int, Function}`: How many times to repeat; can be a predicate.
- `argument::Union{Nothing, Tuple, NamedTuple, Function}`: Arguments for operation.
"""
mutable struct Step
    name::Symbol
    operation::Function
    condition::Function
    repetition::Union{Int, Function}
    argument::Union{Nothing, Tuple, NamedTuple, Function}

    function Step(name::Symbol;
                  operation::Function = (s, r) -> nothing,
                  condition::Function = _ -> true,
                  repetition::Union{Int, Function} = 1,
                  argument::Union{Nothing, Tuple, NamedTuple, Function} = nothing)
        new(name, operation, condition, repetition, argument)
    end
end

"""
Wrap a sequence of steps into a TreeCycle group.
"""
Flow(steps::Vector{Step}) = TreeCycle.Group([TreeCycle.Leaf(step) for step in steps])

"""
Execute a step on the state, handling condition, repetition, and argument resolution.
"""
function step_execute!(step::Step, state::Game, rng::AbstractRNG)
    return step.condition(state) ? _step_execute_do!(step, state, rng) : state
end

function _step_execute_do!(step::Step, state::Game, rng::AbstractRNG)
    prev = get(state.data, :step_current, nothing)
    state.data[:step_current] = step.name

    args = step.argument === nothing ? () :
           step.argument isa Function ? step.argument(state) :
           step.argument

    if step.repetition isa Int
        for _ in 1:step.repetition
            step.operation(state, rng, args...)
        end
    else
        while step.repetition(state)
            step.operation(state, rng, args...)
        end
    end

    state.data[:step_current] = prev
    return state
end

"""
Execute all steps in a TreeCycle group in current cycle order.
"""
function flow_execute!(flow::TreeCycle.Group, state::Game, rng::AbstractRNG)
    index_start = flow.index_current
    is_initial = true

    while is_initial || flow.index_current != index_start
        is_initial = false
        step = TreeCycle.current_get!(flow)
        step_execute!(step, state, rng)
        TreeCycle.advance!(flow)
    end

    return state
end

"""
Return the name of the current step.
"""
step_current_name(state::Game) = get(state.data, :step_current, nothing)

end # module Pipeline