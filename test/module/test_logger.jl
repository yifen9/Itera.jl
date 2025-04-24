using Test
using Itera

@testset "Logger module" begin

    Itera.Logger.clear!()

    @testset "Logger log! and get" begin
        Itera.Logger.log!(:phase; tag=:start, message="Phase started")
        Itera.Logger.log!(:effect; tag=:buff, message="Buff applied")

        logs = Itera.Logger.get()
        @test length(logs) == 2
        @test logs[1].kind == :phase
        @test logs[1].tag == :start
        @test occursin("Phase started", logs[1].message)
        @test logs[2].kind == :effect
    end

    @testset "Logger string output" begin
        log_str = Itera.Logger.string()
        @test isa(log_str, String)
        @test occursin("phase", log_str)
        @test occursin("effect", log_str)
    end

    @testset "Logger save and clear" begin
        tmpfile = tempname() * ".json"
        Itera.Logger.save(tmpfile)

        content = read(tmpfile, String)
        @test occursin("Phase started", content)
        @test occursin("Buff applied", content)

        Itera.Logger.clear!()
        @test length(Itera.Logger.get()) == 0
    end
    
end