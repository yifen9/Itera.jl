#= test/runtests.jl =#

using Test
using Itera

@testset "Itera" begin

    @testset "Module" begin

        @testset "Engine" begin
            
            @testset "Common" begin
                include(joinpath("module", "engine", "common", "rng.jl"))
            end

            @testset "State" begin
                include(joinpath("module", "engine", "state", "state.jl"))
            end
        end
        # include("module/test_rng.jl")
        # include("module/test_participant.jl")
        # include("module/test_phase.jl")
        # include("module/test_state.jl")
        # include("module/test_effect.jl")
        # include("module/test_choice.jl")
        # include("module/test_pipeline.jl")
        # include("module/test_snapshot.jl")
        # include("module/test_tracker.jl")
        # include("module/test_logger.jl")
        # include("module/test_turn.jl")
    end

    @testset "Scenario" begin
        # include("scenario/test_dominion.jl")
    end

end