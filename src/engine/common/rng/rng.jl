module RNG

export AbstractRNG, default, seed!, shuffle, sample

using Random

default(; seed::Union{Int, Nothing}=nothing)::Random.AbstractRNG = Random.MersenneTwister(seed)

function seed!(rng::Random.MersenneTwister, seed::Integer)::Random.MersenneTwister
    Random.seed!(rng, seed)
    return rng
end

shuffle(rng::Random.AbstractRNG, list::AbstractVector)::AbstractVector = Random.shuffle!(rng, copy(list))

function sample(rng::Random.AbstractRNG, list::AbstractVector; number::Int=1, replace::Bool=false)::AbstractVector
    if replace
        return [ rand(rng, list) for _ in 1:number ]
    else
        index = Random.randperm(rng, length(list))[1:number]
        return list[index]
    end
end

end