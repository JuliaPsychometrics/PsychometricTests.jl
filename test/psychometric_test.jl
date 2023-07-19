@testset "PsychometricTest" begin
    @testset "Constructors" begin
        # from matrix
        data = rand(0:1, 10, 3)
        t = PsychometricTest(data)

        @test length(t.items) == 3
        @test length(t.persons) == 10
        @test size(t.responses) == (10, 3)
        @test eltype(t.responses) == BasicResponse{Int}
        @test t.scales == Dict{Symbol,Any}()

        scales = Dict(:s1 => 1:2, :s2 => 3)
        t = PsychometricTest(data; scales)
        @test t.scales == scales

        # from Tables.jl source
        data = (a = rand(0:1, 10), b = rand(0:1, 10), c = rand(0:1, 10))
        t = PsychometricTest(data)

        @test length(t.items) == 3
        @test length(t.persons) == 10
        @test size(t.responses) == (10, 3)
        @test eltype(t.responses) == BasicResponse{Int}
        @test t.scales == Dict{Symbol,Any}()

        t = PsychometricTest(data; scales)
        @test t.scales == scales

        data = (id = 1:10, a = rand(0:1, 10), b = rand(0:1, 10), c = rand(0:1, 10))
        t = PsychometricTest(data, [:a, :b], :id)
        @test length(t.items) == 2
        @test length(t.persons) == 10
        @test size(t.responses) == (10, 2)
    end

    @testset "Accessors" begin
        data = rand(0:1, 10, 3)
        t = PsychometricTest(data, scales = Dict(:s1 => 1:2, :s2 => [3]))

        @test getitems(t) == t.items
        @test length(getitems(t)) == 3

        @test getpersons(t) == t.persons
        @test length(getpersons(t)) == 10

        @test getresponses(t) == t.responses
        @test size(getresponses(t)) == (10, 3)

        @test size(getresponses(t, :s1)) == (10, 2)
        @test size(getresponses(t, :s2)) == (10, 1)
    end

    @testset "response_matrix" begin
        data = [
            0 1
            1 0
            1 1
            0 0
            1 0
        ]

        t = PsychometricTest(data, scales = Dict(:s1 => 1:2, :s2 => 2))
        @test response_matrix(t) == data
        @test response_matrix(t, :s1) == data
        @test response_matrix(t, :s2) == data[:, 2]
    end
end
