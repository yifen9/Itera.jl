using Test
using Itera

@testset "State module" begin

    @testset "State construction" begin
        players = [1, 2, 3]
        actions = Function[(_, _)->nothing, (_, _)->nothing, (_, _)->nothing]
        state = Itera.State.from_player_and_action(players, actions)
        @test state isa Itera.State.Game
        @test length(state.player_group.member_list) == 3
        @test length(state.phase_group.member_list) == 3
    end

    @testset "State accessors" begin
        players = ["a", "b"]
        actions = [(_, _)->1, (_, _)->2]
        state = Itera.State.from_player_and_action(players, actions)
        @test Itera.State.player_current_get(state) == "a"
        @test Itera.State.phase_current_get(state)(state, state.rng) == 1
    end

    @testset "State advancement" begin
        players = ["a", "b"]
        actions = [(_, _)->nothing, (_, _)->nothing]
        state = Itera.State.from_player_and_action(players, actions)
        Itera.State.phase_advance!(state)
        @test Itera.State.phase_current_get(state) == actions[2]
        Itera.State.player_advance!(state)
        @test Itera.State.player_current_get(state) == "b"
    end

    @testset "State reset" begin
        players = ["a", "b"]
        actions = [(_, _)->nothing, (_, _)->nothing]
        state = Itera.State.from_player_and_action(players, actions)
        Itera.State.phase_advance!(state)
        Itera.State.player_advance!(state)
        Itera.State.state_reset!(state)
        @test Itera.State.player_current_get(state) == "a"
        @test Itera.State.phase_current_get(state) == actions[1]
    end

end