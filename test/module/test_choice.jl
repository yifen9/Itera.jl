using Test
using Itera

@testset "Choice module" begin

    @testset "Choice Context creation" begin
        dummy_state = Itera.State.from_player_and_action(["A"], [(_, _)->nothing])
        options = ["x", "y", "z"]
        ctx = Itera.Choice.Context(options, dummy_state, dummy_state.rng; minimum=1, maximum=2)
        @test ctx.minimum == 1
        @test ctx.maximum == 2
        @test length(ctx.option_tree.child_list) == 3
        @test ctx.history == []
    end

    @testset "Choice strategy :random with fixed selection" begin
        dummy_state = Itera.State.from_player_and_action(["A"], [(_, _)->nothing])
        options = [1, 2, 3]
        rng = Itera.RNG.default(seed=42)
        ctx = Itera.Choice.Context(options, dummy_state, rng; minimum=2, maximum=2)
        count = 0
        while true
            res = Itera.Choice.step!(ctx; strategy=:random)
            if res.selection === nothing
                break
            end
            count += 1
        end
        @test length(ctx.history) == 2
        @test count == 2
    end

    @testset "Choice event emission" begin
        dummy_state = Itera.State.from_player_and_action(["A"], [(_, _)->nothing])
        options = ["a", "b"]
        got = Ref("")
        evt = Itera.Effect.Event(:test_event, :my_choice, (s, x)->(got[] = x))
        Itera.Effect.add!(dummy_state, evt)

        ctx = Itera.Choice.Context(options, dummy_state, dummy_state.rng;
                                minimum=1, maximum=1, on_choice_event=:my_choice)
        Itera.Choice.step!(ctx; strategy=:random)
        @test got[] in options
    end

    @testset "Choice on_complete hook" begin
        dummy_state = Itera.State.from_player_and_action(["A"], [(_, _)->nothing])
        options = ["a", "b", "c"]
        completed = Ref(false)

        function on_complete_hook(ctx)
            completed[] = true
        end

        ctx = Itera.Choice.Context(options, dummy_state, dummy_state.rng;
                                minimum=2, maximum=2, on_complete=on_complete_hook)
        while true
            res = Itera.Choice.step!(ctx; strategy=:random)
            if res.selection === nothing
                break
            end
        end
        @test completed[] == true
    end

end