using Test
using Itera

@testset "RNG module" begin

    @testset "RNG default behavior" begin
        rng1 = Itera.RNG.default()
        rng2 = Itera.RNG.default()
        @test typeof(rng1) == typeof(rng2)
    end

    @testset "RNG seeded reproducibility" begin
        rng1 = Itera.RNG.default(seed=123)
        rng2 = Itera.RNG.default(seed=123)
        a = rand(rng1, 1:100)
        b = rand(rng2, 1:100)
        @test a == b
    end

    @testset "RNG shuffle" begin
        rng = Itera.RNG.default(seed=42)
        data = [1, 2, 3, 4, 5]
        shuffled = Itera.RNG.shuffle(rng, data)
        @test length(shuffled) == 5
        @test sort(shuffled) == data
    end

    @testset "RNG sample without replacement" begin
        rng = Itera.RNG.default(seed=101)
        data = [10, 20, 30, 40, 50]
        sample = Itera.RNG.sample(rng, data, 3)
        @test length(sample) == 3
        @test all(x -> x in data, sample)
    end

    @testset "RNG sample with replacement" begin
        rng = Itera.RNG.default(seed=202)
        data = [1, 2, 3]
        sample = Itera.RNG.sample(rng, data, 5; replace=true)
        @test length(sample) == 5
        @test all(x -> x in data, sample)
    end

    @testset "RNG seed! behavior on MersenneTwister" begin
        using Random: MersenneTwister
        rng = MersenneTwister(1)
        Itera.RNG.seed!(rng, 12345)
        a = rand(rng, 1:100)
        rng2 = MersenneTwister(12345)
        b = rand(rng2, 1:100)
        @test a == b
    end

end