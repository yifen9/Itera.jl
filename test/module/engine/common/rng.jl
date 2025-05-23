using Test
using Itera.Engine.Common

@testset "RNG" begin
    
    @testset "Default" begin
        rng_0      = RNG.default(seed = 0)
        rng_1      = RNG.default(seed = 1)
        rng_2      = RNG.default(seed = 2)
        rng_2_copy = RNG.default(seed = 2)

        @test rand(rng_0) !== rand(rng_1)
        @test rand(rng_2) === rand(rng_2_copy)

        rand(rng_2)

        @test rand(rng_2) !== rand(rng_2_copy)

        rand(rng_2_copy)

        @test rand(rng_2) === rand(rng_2_copy)
    end

    @testset "Seed" begin
        data  = [1, 2, 3, 4]
        rng_0 = RNG.default(seed = 0)
        rng_1 = RNG.default(seed = 1)

        @test rand(rng_0) !== rand(rng_1)

        RNG.seed!(rng_1, 0)
        rand(rng_1)

        @test rand(rng_0) === rand(rng_1)
    end

    @testset "Shuffle" begin
        data         = [1, 2, 3, 4]
        rng          = RNG.default(seed = 0)
        data_shuffle = RNG.shuffle(rng, data)

        @test data               == [1, 2, 3, 4]
        @test sort(data_shuffle) == data
    end

    @testset "Sample" begin

        @testset "Default" begin
            data        = [1, 2, 3, 4]
            rng         = RNG.default(seed = 0)
            data_sample = RNG.sample(rng, data)

            @test in(data_sample[1], data)
            @test length(data) === 4
        end

        @testset "Custom" begin

            @testset "number" begin
                data          = [1, 2, 3, 4]
                rng           = RNG.default(seed = 0)
                data_sample_2 = RNG.sample(rng, data; number=2)
                data_sample_4 = RNG.sample(rng, data; number=4)

                @test length(data_sample_2) === 2
                @test sort(data_sample_4)   ==  data
            end

            @testset "replace" begin
                data        = [1, 2, 3, 4]
                rng         = RNG.default(seed = 0)
                data_sample = RNG.sample(rng, data; number=8, replace=true)

                @test length(data_sample) === 8
            end
        end

        @testset "error" begin
            data = [1, 2, 3, 4]
            rng  = RNG.default(seed = 0)
            @test_throws BoundsError RNG.sample(rng, data; number=8)
        end
    end
end