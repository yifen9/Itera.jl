module RNG

export default, shuffle, sample, seed!

using Random

"""
default(; seed::Union{Int,Nothing}=nothing) -> AbstractRNG

Get a default RNG instance:
- Without `seed`: returns the task-local global RNG (`Random.default_rng()`).
- With `seed`: returns a new `MersenneTwister(seed)` for deterministic sequences.
"""
default(; seed::Union{Int,Nothing}=nothing) =
    (seed === nothing) ? Random.default_rng() : MersenneTwister(seed)

"""
shuffle(rng::AbstractRNG, collection::AbstractVector) -> Vector{T}

Return a shuffled copy of `collection`.
"""
shuffle(rng::AbstractRNG, collection::AbstractVector) =
    Random.shuffle!(rng, copy(collection))

"""
sample(rng::AbstractRNG, collection::AbstractVector, number::Int; replace::Bool=false) -> Vector{T}

Draw `number` elements from `collection`:
- `replace=false` (default): sampling without replacement
- `replace=true`: sampling with replacement
"""
function sample(rng::AbstractRNG, collection::AbstractVector, number::Int; replace::Bool=false)
    if replace
        return [rand(rng, collection) for _ in 1:number]
    else
        # Generate a random permutation of indices and select first `number`
        index_selection = Random.randperm(rng, length(collection))[1:number]
        return collection[index_selection]
    end
end

"""
seed!(rng::MersenneTwister, seed::Integer) -> AbstractRNG

Reseed a `MersenneTwister` RNG; returns the same instance.
For other RNG types, calling `seed!` is a no-op.
"""
function seed!(rng::MersenneTwister, seed::Integer)
    Random.seed!(rng, seed)
    return rng
end

# No-op for non-MersenneTwister RNG types
seed!(rng::AbstractRNG, _) = rng

end # module RNG