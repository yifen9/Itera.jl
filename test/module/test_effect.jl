using Test
using Itera

@testset "Effect module" begin

    @testset "add! and remove!" begin
        state = Itera.State.from_player_and_action(["p"], [(_, _)->nothing])
        effect = Itera.Effect.Timed(:tick, 3, _ -> nothing)

        @test !haskey(state.data, :effect)

        Itera.Effect.add!(state, effect)
        @test get(state.data, :effect, nothing) isa Vector
        @test length(state.data[:effect]) == 1

        Itera.Effect.remove!(state, :tick)
        @test isempty(state.data[:effect])
    end

    @testset "apply! for Timed effect" begin
        count = Ref(0)
        effect = Itera.Effect.Timed(:buff, 2, _ -> count[] += 1)
        state = Itera.State.from_player_and_action(["p"], [(_, _)->nothing])
        Itera.Effect.add!(state, effect)

        Itera.Effect.apply!(state)
        @test count[] == 1
        @test length(state.data[:effect]) == 1  # still remains

        Itera.Effect.apply!(state)
        @test count[] == 2
        @test isempty(state.data[:effect])  # removed
    end

    @testset "apply! for Conditional effect" begin
        counter = Ref(0)
        effect = Itera.Effect.Conditional(:flag, _ -> true, _ -> counter[] += 1)
        state = Itera.State.from_player_and_action(["p"], [(_, _)->nothing])
        Itera.Effect.add!(state, effect)

        Itera.Effect.apply!(state)
        @test counter[] == 1
        @test length(state.data[:effect]) == 1  # stays
    end

    @testset "Conditional effect not triggered if condition false" begin
        counter = Ref(0)
        effect = Itera.Effect.Conditional(:skip, _ -> false, _ -> counter[] += 1)
        state = Itera.State.from_player_and_action(["p"], [(_, _)->nothing])
        Itera.Effect.add!(state, effect)

        Itera.Effect.apply!(state)
        @test counter[] == 0
        @test length(state.data[:effect]) == 1
    end

    @testset "event_emit! for matching event" begin
        record = Ref("")
        event = Itera.Effect.Event(:hook, :on_custom, (s, args...) -> record[] = args[1])
        state = Itera.State.from_player_and_action(["p"], [(_, _)->nothing])
        Itera.Effect.add!(state, event)

        Itera.Effect.event_emit!(state, :on_custom, "✅")
        @test record[] == "✅"
    end

    @testset "event_emit! should not trigger unmatched events" begin
        record = Ref("init")
        event = Itera.Effect.Event(:only_this, :correct_event, (s, args...) -> record[] = args[1])
        state = Itera.State.from_player_and_action(["p"], [(_, _)->nothing])
        Itera.Effect.add!(state, event)

        Itera.Effect.event_emit!(state, :wrong_event, "🚫")
        @test record[] == "init"
    end

    @testset "event_emit! should handle listener in state.data[:listener]" begin
        seen = Ref("")
        state = Itera.State.from_player_and_action(["p"], [(_, _)->nothing])
        state.data[:listener] = Dict(:ping => (s, args...) -> seen[] = args[1])

        Itera.Effect.event_emit!(state, :ping, "pong")
        @test seen[] == "pong"
    end

end