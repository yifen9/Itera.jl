#= test/runtests.jl =#

using Test
using Itera

@testset "Itera tests" begin

    @testset "Module tests" begin
        include("module/test_tree_cycle.jl")
        include("module/test_rng.jl")
        include("module/test_participant.jl")
        include("module/test_phase.jl")
        include("module/test_state.jl")
        include("module/test_effect.jl")
        include("module/test_choice.jl")
        include("module/test_pipeline.jl")
        include("module/test_snapshot.jl")
        include("module/test_tracker.jl")
        include("module/test_logger.jl")
        include("module/test_turn.jl")
    end

    @testset "Scenario tests" begin
        include("scenario/test_dominion.jl")
    end

end