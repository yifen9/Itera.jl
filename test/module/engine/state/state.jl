using Test
using Itera.Engine.Common
using Itera.Engine.State

@testset "State" begin
    
    @testset "Build" begin
        context = State.Context(TSM.Engine.Builder.build([1, [2, 3], 4]), TSM.Engine.Builder.build([1, [2, 3], 4]))

        @show context
    end
end