@testset "PsychometricTest" begin
    data = [
        0 1
        1 1
        1 0
    ]

    t = PsychometricTest(data)

    @test length(t.items) == 2
    @test length(t.persons) == 3
    @test length(t.responses) == 6

    tbl = Tables.table(data)
    @test PsychometricTest(tbl) isa PsychometricTest
    @test length(PsychometricTest(tbl).items) == 2
    @test length(PsychometricTest(tbl).persons) == 3
    @test length(PsychometricTest(tbl).responses) == 6

    @testset "getindex" begin
        responses_p1 =
            responses_p2 = @test t[1, :] == [BasicResponse(1, 1, 0), BasicResponse(2, 1, 1)]
        @test t[1:2, :] == [
            BasicResponse(1, 1, 0) BasicResponse(2, 1, 1)
            BasicResponse(1, 2, 1) BasicResponse(2, 2, 1)
        ]

        @test t[:, 1] ==
              [BasicResponse(1, 1, 0), BasicResponse(1, 2, 1), BasicResponse(1, 3, 1)]
        @test t[:, 1:2] == [
            BasicResponse(1, 1, 0) BasicResponse(2, 1, 1)
            BasicResponse(1, 2, 1) BasicResponse(2, 2, 1)
            BasicResponse(1, 3, 1) BasicResponse(2, 3, 0)
        ]
    end

    @testset "Accessors" begin
        @test getpersons(t) == [BasicPerson(p) for p in 1:3]
        @test getitems(t) == [BasicItem(i) for i in 1:2]
        @test getresponses(t) ==
              vec([BasicResponse(i, p, data[p, i]) for p in 1:3, i in 1:2])

        @test nitems(t) == 2
        @test npersons(t) == 3
        @test nresponses(t) == 6
    end

    @testset "Matrix" begin
        @test Matrix(t) == data
    end
end
