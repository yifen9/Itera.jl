module Effect

export Base, Timed, Conditional, Event,
       add!, remove!, apply!, event_emit!

using ..State

"""
`Base` is the abstract base for all persistent game effects.
"""
abstract type Base end

"""
`Timed(name, duration, operation)`

An effect that applies `operation(state)` each step, lasting for `duration` steps.
- `name`::Symbol: identifier
- `duration`::Int: remaining steps
- `operation`::Function(state::Game) -> Any: applied each step
"""
mutable struct Timed <: Base
    name::Symbol
    duration::Int
    operation::Function
end

"""
`Conditional(name, condition, operation)`

An effect that applies `operation(state)` whenever `condition(state)` is true.
- `name`::Symbol: identifier
- `condition`::Function(state::Game) -> Bool
- `operation`::Function(state::Game) -> Any
"""
mutable struct Conditional <: Base
    name::Symbol
    condition::Function
    operation::Function
end

"""
`Event(name, event, callback)`

An effect that triggers `callback(state, args...)` when `event` is emitted.
- `name`::Symbol: identifier
- `event`::Symbol: event key
- `callback`::Function(state::Game, args...) -> Any
"""
mutable struct Event <: Base
    name::Symbol
    event::Symbol
    callback::Function
end

"""
add!(state, effect) -> state

Add a `Base` effect to `state.data[:effect]`.
"""
function add!(state::Game, effect::Base)
    lst = get!(state.data, :effect, [])
    push!(lst, effect)
    state.data[:effect] = lst
    return state
end

"""
remove!(state, name) -> state

Remove all effects with matching `name`.
"""
function remove!(state::Game, name::Symbol)
    if haskey(state.data, :effect)
        state.data[:effect] = filter(e -> e.name != name, state.data[:effect])
    end
    return state
end

"""
apply!(state) -> state

Apply all effects in `state.data[:effect]` once:
- For `Timed`: apply `operation`, decrement `duration`, remove if `duration <= 0`
- For `Conditional`: if `condition(state)` is true, apply `operation`
- Keep `Event` for future `event_emit!`
"""
function apply!(state::Game)
    if !haskey(state.data, :effect)
        return state
    end
    list_new = Base[]
    for e in state.data[:effect]
        if e isa Timed
            e.operation(state)
            e.duration -= 1
            if e.duration > 0
                push!(list_new, e)
            end
        elseif e isa Conditional
            if e.condition(state)
                e.operation(state)
            end
            push!(list_new, e)
        elseif e isa Event
            push!(list_new, e)
        end
    end
    state.data[:effect] = list_new
    return state
end

"""
event_emit!(state, event, args...) -> state

Emit an event, invoking all `Event` callbacks matching `event`,
as well as all listener callbacks in `state.data[:listener]`.
"""
function event_emit!(state::Game, event::Symbol, args...)
    if haskey(state.data, :effect)
        for e in state.data[:effect]
            if e isa Event && e.event == event
                e.callback(state, args...)
            end
        end
    end
    if haskey(state.data, :listener)
        for (evt, callback) in state.data[:listener]
            if evt == event
                callback(state, args...)
            end
        end
    end
    return state
end

end # module Effect