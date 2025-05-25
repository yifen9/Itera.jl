module State

export Context, equal

using ..Common

mutable struct Context
    player::TSM.Engine.Model.Node
    stage::TSM.Engine.Model.Node
    rng::RNG.AbstractRNG
    meta::AbstractDict{Symbol, Any}
end

Context(
    player::TSM.Engine.Model.Node,
    stage::TSM.Engine.Model.Node;
    rng::RNG.AbstractRNG            = RNG.default(),
    meta::AbstractDict{Symbol, Any} = Dict{Symbol, Any}()
)::Context = Context(
    player,
    stage,
    rng,
    meta
)

equal(context_a::Context, context_b::Context)::Bool = (
    TSM.Engine.Model.equal(context_a.player, context_b.player) &&
    TSM.Engine.Model.equal(context_a.stage, context_b.stage)   &&
    context_a.rng  === context_b.rng                           &&
    context_a.meta ==  context_b.meta
)

end