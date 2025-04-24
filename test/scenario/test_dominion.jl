using Test
using Itera

@testset "Scenario Dominion" begin

    @testset "action + effects + player rotation" begin
        log = Ref(String[])
        phase_fn = (s, r) -> nothing

        village = Itera.Pipeline.Step(:village, operation=(s, rng)->push!(log[], "village"))
        smithy = Itera.Pipeline.Step(:smithy, operation=(s, rng)->push!(log[], "smithy"))

        Itera.Choice.strategy_register(:always, (c, ctx)->Itera.Choice.Result(c))

        state = Itera.State.from_player_and_action(["Alice", "Bob"], [phase_fn, phase_fn])
        Itera.Effect.add!(state, Itera.Effect.Event(:e1, :on_smithy, (s, args...) -> push!(log[], "cond")))
        Itera.Effect.add!(state, Itera.Effect.Timed(:buff, 3, s->push!(log[], "buff")))

        Itera.Turn.execute!(state, [village, smithy]; minimum=2, maximum=2, strategy=:always)
        Itera.Turn.execute!(state, [village]; minimum=1, maximum=1, strategy=:always)

        expected = ["buff", "village", "buff", "smithy", "cond", "buff", "village"]
        @test log[] == expected
        @test Itera.State.player_current_get(state) == "Alice"
        @test length(get(state.data, :effect, [])) == 1
    end

    @testset "chained action (Throne Room)" begin
        trace = Ref([])
        step = Itera.Pipeline.Step(:gain, operation=(s, r)->push!(trace[], :gained))
        thr = Itera.Pipeline.Step(:throne, operation=(s, r)->begin
            Itera.Pipeline.step_execute!(step, s, r)
            Itera.Pipeline.step_execute!(step, s, r)
        end)
        state = Itera.State.from_player_and_action(["p"], [(_, _)->nothing])
        Itera.Turn.execute!(state, [thr]; minimum=1, maximum=1, strategy=:always)
        @test trace[] == [:gained, :gained]
    end

    @testset "dynamic choice & limit reached" begin
        counter = Ref(0)
        step = Itera.Pipeline.Step(:step, operation=(s, r)->(counter[] += 1))
        state = Itera.State.from_player_and_action(["x"], [(_, _)->nothing])
        Itera.Choice.strategy_register(:limited, (c, ctx)->length(ctx.history) < 2 ? Itera.Choice.Result(c) : Itera.Choice.Result(nothing))
        Itera.Turn.execute!(state, [step, step, step]; minimum=0, maximum=2, strategy=:limited)
        @test counter[] == 2
    end

    @testset "phase-specific effects and step interaction" begin
        phase_count = Ref(0)
        step_trace = Ref([])
        phase_fn = (s, r) -> (phase_count[] += 1)
        step = Itera.Pipeline.Step(:x, operation=(s, r)->push!(step_trace[], :steped))
        state = Itera.State.from_player_and_action(["p"], [phase_fn])
        Itera.Effect.add!(state, Itera.Effect.Timed(:shadow, 2, s->push!(step_trace[], :shadowed)))
        Itera.Turn.execute!(state, [step]; minimum=1, maximum=1, strategy=:always)
        @test phase_count[] == 1
        @test step_trace[] == [:shadowed, :steped, :shadowed]
    end

    @testset "attack card triggers reaction" begin
        trace = Ref([])
        attacker = Itera.Pipeline.Step(:militia, operation=(s, r)->begin
            Itera.Effect.event_emit!(s, :on_attack)
            push!(trace[], :attack_done)
        end)
        phase_fn = (_, _) -> nothing
        state = Itera.State.from_player_and_action(["p1", "p2"], [phase_fn, phase_fn])
        Itera.Effect.add!(state, Itera.Effect.Conditional(:on_attack, s -> true, s -> push!(trace[], :reaction_triggered)))
        Itera.Turn.execute!(state, [attacker]; minimum=1, maximum=1, strategy=:always)
        @test :attack_done in trace[]
        @test :reaction_triggered in trace[]
    end

    @testset "recursive step call and effect leak check" begin
        counter = Ref(0)
        phase_fn = (_, _) -> nothing
        s = Itera.Pipeline.Step(:a, operation=(s, r)->begin
            counter[] += 1
            Itera.Pipeline.step_execute!(Itera.Pipeline.Step(:b, operation=(s, r)->(counter[] += 1)), s, r)
        end)
        state = Itera.State.from_player_and_action(["X"], [phase_fn])
        Itera.Turn.execute!(state, [s]; minimum=1, maximum=1, strategy=:always)
        @test counter[] == 2
    end

end