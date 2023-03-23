@testset "PsychometricTest" begin
    @test_throws ArgumentError PsychometricTest(
        fill(BasicItem(1), 2),
        [BasicPerson(1)],
        [BasicResponse(1, 1, 1)],
    )

    @test_throws ArgumentError PsychometricTest(
        [BasicItem(1)],
        fill(BasicPerson(1), 2),
        [BasicResponse(1, 1, 1)],
    )

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

    @testset "Setters" begin
        t = PsychometricTest(data)

        # additems!
        @test additems!(t, BasicItem(3)) == [BasicItem(i) for i in 1:3]
        @test nitems(t) == 3
        @test_throws ArgumentError additems!(t, BasicItem(3))

        @test additems!(t, [BasicItem(i) for i in 4:5]) == [BasicItem(i) for i in 1:5]
        @test nitems(t) == 5
        @test_throws ArgumentError additems!(t, [BasicItem(4)])

        # addpersons!
        @test addpersons!(t, BasicPerson(4)) == [BasicPerson(p) for p in 1:4]
        @test npersons(t) == 4
        @test_throws ArgumentError addpersons!(t, BasicPerson(1))

        @test addpersons!(t, [BasicPerson(p) for p in 5:6]) == [BasicPerson(p) for p in 1:6]
        @test npersons(t) == 6
        @test_throws ArgumentError addpersons!(t, [BasicPerson(1)])

        # addresponses!
        t = PsychometricTest(data)
        @test_throws ArgumentError addresponses!(t, BasicResponse(10, 1, 1))
        @test_throws ArgumentError addresponses!(t, BasicResponse(1, 10, 1))
        @test_throws ArgumentError addresponses!(t, BasicResponse(1, 1, 1))

        oldt = deepcopy(t)
        addpersons!(t, BasicPerson(4))

        new_responses = [BasicResponse(i, 4, 1) for i in 1:2]
        @test addresponses!(t, new_responses) == vcat(getresponses(oldt), new_responses)
        @test oldt.person_ptr != t.person_ptr
        @test oldt.item_ptr != t.item_ptr
        @test t[4, :] == new_responses

        for p in 1:3
            @test t[p, :] == oldt[p, :]
        end

        for i in 1:2
            @test t[1:3, [i]] == oldt[1:3, [i]]
        end

        # manual invalidation
        t2 = deepcopy(oldt)
        addpersons!(t2, BasicPerson(4))
        addresponses!(t2, new_responses, invalidate = false)
        @test oldt.person_ptr == t2.person_ptr
        @test oldt.item_ptr == t2.item_ptr

        invalidate!(t2)
        @test t2.person_ptr == t.person_ptr
        @test t2.item_ptr == t2.item_ptr
    end

    @testset "Matrix" begin
        t = PsychometricTest(data)
        @test Matrix(t) == data
        @test eltype(Matrix(t)) == Int

        addpersons!(t, BasicPerson(4))
        addresponses!(t, BasicResponse(1, 4, 1))
        @test eltype(Matrix(t)) == Union{Missing,Int}
    end
end
