using Test
using Itera

@testset "Pipeline Module" begin

    @testset "Pipeline Step execution (static args)" begin
        hits = Ref(0)
        step = Itera.Pipeline.Step(
            :add1,
            operation=(s, rng, x)->(hits[] += x),
            argument=(2,)
        )
        state = Itera.State.from_player_and_action(["p"], [(_, _)->nothing])
        Itera.Pipeline.step_execute!(step, state, state.rng)
        @test hits[] == 2
    end

    @testset "Pipeline Step execution (dynamic args)" begin
        hits = Ref(0)
        step = Itera.Pipeline.Step(
            :add2,
            operation=(s, rng, x)->(hits[] += x),
            argument=s->(3,)
        )
        state = Itera.State.from_player_and_action(["p"], [(_, _)->nothing])
        Itera.Pipeline.step_execute!(step, state, state.rng)
        @test hits[] == 3
    end

    @testset "Pipeline Step repetition (fixed and conditional)" begin
        hits = Ref(0)
        fixed_step = Itera.Pipeline.Step(
            :fixed,
            operation=(s, rng)->(hits[] += 1),
            repetition=3
        )
        cond_step = Itera.Pipeline.Step(
            :cond,
            operation=(s, rng)->(hits[] += 1),
            repetition=let count=Ref(3); s->(count[] -= 1) ≥ 0 end
        )
        state = Itera.State.from_player_and_action(["p"], [(_, _)->nothing])
        Itera.Pipeline.step_execute!(fixed_step, state, state.rng)
        @test hits[] == 3
        Itera.Pipeline.step_execute!(cond_step, state, state.rng)
        @test hits[] == 6
    end

    @testset "Pipeline Flow execution in order" begin
        history = String[]
        step1 = Itera.Pipeline.Step(:s1, operation=(s, rng)->push!(history, "a"))
        step2 = Itera.Pipeline.Step(:s2, operation=(s, rng)->push!(history, "b"))
        flow = Itera.Pipeline.Flow([step1, step2])
        state = Itera.State.from_player_and_action(["p"], [(_, _)->nothing])
        Itera.Pipeline.flow_execute!(flow, state, state.rng)
        @test history == ["a", "b"]
    end

end