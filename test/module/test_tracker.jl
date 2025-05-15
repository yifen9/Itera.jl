using Test
using Itera

@testset "Tracker module" begin

    @testset "Tracker basic recording" begin
        Itera.Tracker.clear!()
        state = Itera.State.from_player_and_action(["a"], [(_, _)->nothing])
        
        @test length(Itera.Tracker.get()) == 0

        Itera.Tracker.track!(state)
        Itera.Tracker.track!(state)
        @test length(Itera.Tracker.get()) == 2
    end

    @testset "Tracker snapshot integrity" begin
        Itera.Tracker.clear!()
        state = Itera.State.from_player_and_action(["a"], [(_, _)->nothing])
        Itera.Tracker.track!(state)
        
        snapshots = Itera.Tracker.get()
        @test length(snapshots) == 1
        snap = snapshots[1]
        
        # Ensure snapshot is deepcopied (not the same object)
        @test snap !== state
        @test snap.player_group.child_list[1].value == "a"
    end

    @testset "Tracker clear!" begin
        Itera.Tracker.clear!()
        
        state = Itera.State.from_player_and_action(["a"], [(_, _)->nothing])
        Itera.Tracker.track!(state)
        Itera.Tracker.track!(state)

        @test length(Itera.Tracker.get()) == 2

        Itera.Tracker.clear!()
        @test length(Itera.Tracker.get()) == 0
    end

    @testset "Tracker save as JSON summary" begin
        Itera.Tracker.clear!()
        state = Itera.State.from_player_and_action(["a"], [(_, _)->nothing])
        Itera.Tracker.track!(state)
        Itera.Tracker.track!(state)
        
        tmpfile = tempname() * ".json"
        Itera.Tracker.save(tmpfile)
        
        content = read(tmpfile, String)
        @test occursin("\"player\"", content)
        @test occursin("\"phase\"", content)
        @test occursin("\"effect_count\"", content)
    end

end