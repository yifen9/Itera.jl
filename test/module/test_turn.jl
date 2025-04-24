using Test
using Itera

@testset "Turn module" begin

    @testset "Basic action is executed within range" begin
        count = Ref(0)
        step = Itera.Pipeline.Step(:action, operation = (s, rng) -> count[] += 1)

        state = Itera.State.from_player_and_action(["p1", "p2"], [(_, _)->nothing])
        actions = [step, step, step]

        # Uses default :random strategy, only ensures upper bound
        Itera.Turn.execute!(state, actions; minimum=1, maximum=2, strategy=:random)

        @test 0 ≤ count[] ≤ 2
    end

    @testset "Guaranteed strategy triggers exact number of actions" begin
        count = Ref(0)
        step = Itera.Pipeline.Step(:always_hit, operation = (s, rng) -> count[] += 1)

        Itera.Choice.strategy_register(:always, (c, ctx) -> Itera.Choice.Result(c))

        state = Itera.State.from_player_and_action(["p1"], [(_, _)->nothing])
        actions = [step, step]

        Itera.Turn.execute!(state, actions; minimum=2, maximum=2, strategy=:always)
        @test count[] == 2
    end

    @testset "Effect hooks run before and after each step" begin
        log = Ref([])

        # Define effect: pre-step effect (Timed)
        effect = Itera.Effect.Timed(:prelog, 2, s -> push!(log[], :pre))
        step = Itera.Pipeline.Step(:do, operation = (s, rng) -> push!(log[], :do))

        state = Itera.State.from_player_and_action(["p"], [(_, _)->nothing])
        Itera.Effect.add!(state, effect)

        Itera.Choice.strategy_register(:once, (c, ctx) -> Itera.Choice.Result(c))
        Itera.Turn.execute!(state, [step]; minimum=1, maximum=1, strategy=:once)

        @test log[] == [:pre, :do, :pre]
    end

    @testset "Events trigger when an action is selected" begin
        triggered = Ref{Union{Symbol,Nothing}}(nothing)

        # Create Event hook
        evt = Itera.Effect.Event(:hook, :on_action_chosen, (s, step) -> triggered[] = step.name)
        state = Itera.State.from_player_and_action(["p"], [(_, _)->nothing])
        Itera.Effect.add!(state, evt)

        step = Itera.Pipeline.Step(:flame, operation = (s, r) -> nothing)

        Itera.Choice.strategy_register(:flame_all, (c, ctx) -> Itera.Choice.Result(c))
        Itera.Turn.execute!(state, [step]; minimum=1, maximum=1, strategy=:flame_all)

        @test triggered[] == :flame
    end

    @testset "Phase and player rotation happens correctly" begin
        phase1 = Ref(false)
        phase_fn = (s, r) -> phase1[] = true

        state = Itera.State.from_player_and_action(["A", "B"], [phase_fn, (_, _)->nothing])
        step = Itera.Pipeline.Step(:act, operation = (s, r) -> nothing)

        Itera.Choice.strategy_register(:do_once, (c, ctx) -> Itera.Choice.Result(c))
        Itera.Turn.execute!(state, [step]; minimum=1, maximum=1, strategy=:do_once)

        @test phase1[]
        @test Itera.State.player_current_get(state) == "B"
    end

end