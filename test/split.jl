@testset "Test splitting" begin
    test = PsychometricTest(rand(0:1, 100, 10))

    @testset "subset" begin
        subtest = subset(test, :, 1:5)
        @test getpersons(subtest) == getpersons(test)
        @test getitems(subtest) == getitems(test)[1:5]
        @test response_matrix(subtest) == response_matrix(test)[:, 1:5]

        subtest = subset(test, 1:2:100, :)
        @test getpersons(subtest) == getpersons(test)[1:2:100]
        @test getitems(subtest) == getitems(test)
        @test Matrix(response_matrix(subtest)) == Matrix(response_matrix(test)[1:2:100, :])

        subtest = subset(test, 1:2, 1:5)
        @test getpersons(subtest) == getpersons(test)[1:2]
        @test getitems(subtest) == getitems(test)[1:5]
        @test Matrix(response_matrix(subtest)) == Matrix(response_matrix(test)[1:2, 1:5])

        subtest_copy = subset(test, 1:2, 1:8, view = false)
        subtest_view = subset(test, 1:2, 1:8, view = true)
        @test getpersons(subtest_copy) == getpersons(subtest_view)
        @test getitems(subtest_copy) == getitems(subtest_view)
        @test getresponses(subtest_copy) == getresponses(subtest_view)
    end

    @testset "split" begin
        @test_throws ArgumentError split(test, :, 1:11)
        @test_throws ArgumentError split(test, :, 0:2)
        @test_throws MethodError split(test, 1:10, 1:2)

        s1, s2 = split(test, :, 1:5)
        @test length(getitems(s1)) == 5
        @test length(getitems(s2)) == 5
        @test length(getpersons(s1)) == 100
        @test length(getpersons(s2)) == 100
        @test length(getresponses(s1)) == 500
        @test length(getresponses(s2)) == 500

        s1, s2 = split(test, 1:2:100, :)
        @test length(getitems(s1)) == 10
        @test length(getitems(s2)) == 10
        @test length(getpersons(s1)) == 50
        @test length(getpersons(s2)) == 50
        @test length(getresponses(s1)) == 500
        @test length(getresponses(s2)) == 500
    end
end
