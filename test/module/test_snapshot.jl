using Test
using Itera

using UUIDs

@testset "Snapshot module" begin

    players = ["a", "b"]
    actions = [(_, _)->nothing, (_, _)->nothing]
    state = Itera.State.from_player_and_action(players, actions)

    @testset "snapshot returns deepcopy" begin
        snap = Itera.Snapshot.snapshot(state)
        @test snap !== state
        @test snap.player_group.member_list[1].value == state.player_group.member_list[1].value
    end

    @testset "save and load snapshot (JLSO)" begin
        tmpfile = tempname() * ".jlso"
        Itera.Snapshot.save(state, tmpfile)
        loaded = Itera.Snapshot.load(tmpfile)

        @test loaded !== state
        @test loaded.player_group.member_list[1].value == "a"
        @test typeof(loaded) == typeof(state)
    end

    @testset "summarize produces correct keys" begin
        summary = Itera.Snapshot.summarize(state)
        @test haskey(summary, :player)
        @test haskey(summary, :phase)
        @test haskey(summary, :effect_count)
        @test summary.effect_count == 0
    end

end