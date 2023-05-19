@testset "Test splitting" begin
    test = PsychometricTest(rand(0:1, 100, 10))

    @testset "split by item" begin
        @test_throws BoundsError split(test, :, 1:11)
        @test_throws BoundsError split(test, :, 0:2)

        s1, s2 = split(test, :, 1:5)
        @test nitems(s1) == 5
        @test npersons(s1) == 100
        @test all(itemscores(s1) .<= 100)
        @test all(personscores(s1) .<= 5)

        @test nitems(s2) == 5
        @test npersons(s2) == 100
        @test all(itemscores(s2) .<= 100)
        @test all(personscores(s2) .<= 5)
    end

    @testset "split by person" begin
        @test_throws BoundsError split(test, 0:1, :)
        @test_throws BoundsError split(test, 100:101, :)

        s1, s2 = split(test, 1:10, :)
        @test nitems(s1) == 10
        @test npersons(s1) == 10

        @test nitems(s2) == 10
        @test npersons(s2) == 90
    end
end
