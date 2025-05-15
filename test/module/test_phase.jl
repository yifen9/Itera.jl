using Test
using Itera

@testset "Phase module" begin

    @testset "Phase basic" begin
        a = (_...)->:A
        b = (_...)->:B
        group = Itera.Phase.Group([Itera.Phase.Leaf(a), Itera.Phase.Leaf(b)])

        @test Itera.Phase.current_get(group)(nothing, nothing) == :A
        Itera.Phase.advance!(group)
        @test Itera.Phase.current_get(group)(nothing, nothing) == :B
        Itera.Phase.advance!(group)
        @test Itera.Phase.current_get(group)(nothing, nothing) == :A
    end

    @testset "Phase nested traversal" begin
        a = (_...)->:A
        b = (_...)->:B
        c = (_...)->:C
        inner = Itera.Phase.Group([Itera.Phase.Leaf(a), Itera.Phase.Leaf(b)])
        outer = Itera.Phase.Group([inner, Itera.Phase.Leaf(c)])

        @test Itera.Phase.current_get(outer)(nothing, nothing) == :A
        Itera.Phase.advance!(outer)
        @test Itera.Phase.current_get(outer)(nothing, nothing) == :B
        Itera.Phase.advance!(outer)
        @test Itera.Phase.current_get(outer)(nothing, nothing) == :C
        Itera.Phase.advance!(outer)
        @test Itera.Phase.current_get(outer)(nothing, nothing) == :A
    end

    @testset "Phase reset" begin
        a = (_...)->:A
        b = (_...)->:B
        group = Itera.Phase.Group([Itera.Phase.Leaf(a), Itera.Phase.Leaf(b)])
        Itera.Phase.advance!(group)
        Itera.Phase.reset!(group)
        @test Itera.Phase.current_get(group)(nothing, nothing) == :A
    end

end