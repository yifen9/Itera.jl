using Test
using Itera

@testset "Participant module" begin

    @testset "Participant tree basic operations" begin
        leaf1 = Itera.Participant.Leaf("Alice")
        leaf2 = Itera.Participant.Leaf("Bob")
        group = Itera.Participant.Group([leaf1, leaf2])

        @test Itera.Participant.current_get(group) == "Alice"
        Itera.Participant.advance!(group)
        @test Itera.Participant.current_get(group) == "Bob"
        Itera.Participant.advance!(group)
        @test Itera.Participant.current_get(group) == "Alice"
    end

    @testset "Participant tree nested operations" begin
        leaf1 = Itera.Participant.Leaf("A")
        leaf2 = Itera.Participant.Leaf("B")
        inner = Itera.Participant.Group([leaf1, leaf2])
        leaf3 = Itera.Participant.Leaf("C")
        outer = Itera.Participant.Group([inner, leaf3])

        @test Itera.Participant.current_get(outer) == "A"
        Itera.Participant.advance!(outer)
        @test Itera.Participant.current_get(outer) == "B"
        Itera.Participant.advance!(outer)
        @test Itera.Participant.current_get(outer) == "C"
        Itera.Participant.advance!(outer)
        @test Itera.Participant.current_get(outer) == "A"
    end

    @testset "Participant reset!" begin
        leaf1 = Itera.Participant.Leaf("X")
        leaf2 = Itera.Participant.Leaf("Y")
        group = Itera.Participant.Group([leaf1, leaf2])
        Itera.Participant.advance!(group)
        Itera.Participant.reset!(group)
        @test Itera.Participant.current_get(group) == "X"
    end

end