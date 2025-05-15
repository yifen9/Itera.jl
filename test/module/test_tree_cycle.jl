using Test
using Itera

@testset "TreeCycle module"  begin

    @testset "TreeCycle Leaf and Group construction" begin
        leaf1 = Itera.TreeCycle.Leaf(42)
        leaf2 = Itera.TreeCycle.Leaf("hello")
        group = Itera.TreeCycle.Group([leaf1, leaf2])
        @test leaf1.value == 42
        @test leaf2.value == "hello"
        @test group.child_index_current == 1
        @test length(group.child_list) == 2
    end

    @testset "TreeCycle current_get" begin
        leaf1 = Itera.TreeCycle.Leaf("a")
        leaf2 = Itera.TreeCycle.Leaf("b")
        group = Itera.TreeCycle.Group([leaf1, leaf2])
        @test Itera.TreeCycle.current_get(leaf1) == "a"
        @test Itera.TreeCycle.current_get(group) == "a"
        Itera.TreeCycle.advance!(group)
        @test Itera.TreeCycle.current_get(group) == "b"
    end

    @testset "TreeCycle advance! with nested groups" begin
        leaf1 = Itera.TreeCycle.Leaf(1)
        leaf2 = Itera.TreeCycle.Leaf(2)
        inner_group = Itera.TreeCycle.Group([leaf1, leaf2])
        outer_leaf = Itera.TreeCycle.Leaf(3)
        group = Itera.TreeCycle.Group([inner_group, outer_leaf])

        @test Itera.TreeCycle.current_get(group) == 1
        Itera.TreeCycle.advance!(group) # inner advances
        @test Itera.TreeCycle.current_get(group) == 2
        Itera.TreeCycle.advance!(group) # inner resets, outer moves
        @test Itera.TreeCycle.current_get(group) == 3
        Itera.TreeCycle.advance!(group) # outer wraps
        @test Itera.TreeCycle.current_get(group) == 1
    end

    @testset "TreeCycle reset!" begin
        leaf1 = Itera.TreeCycle.Leaf(10)
        leaf2 = Itera.TreeCycle.Leaf(20)
        group = Itera.TreeCycle.Group([leaf1, leaf2])
        Itera.TreeCycle.advance!(group)
        @test group.child_index_current == 2
        Itera.TreeCycle.reset!(group)
        @test group.child_index_current == 1
    end

    @testset "TreeCycle advance! error on leaf" begin
        leaf = Itera.TreeCycle.Leaf("x")
        @test_throws ErrorException Itera.TreeCycle.advance!(leaf)
    end

end