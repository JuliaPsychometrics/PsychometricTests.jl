@testset "Descriptive statistics" begin
    data = rand(0:1, 10, 3)
    test = PsychometricTest(data)

    @test personscore(test, 1) == sum(data[1, :])
    @test personscores(test) == vec(sum(data, dims = 2))

    @test itemscore(test, 2) == sum(data[:, 2])
    @test itemscores(test) == vec(sum(data, dims = 1))
    @test itemmean(test, 1) == mean(data[:, 1])
    @test itemmeans(test) == vec(mean(data, dims = 1))

    data = (; id = [:a, :b], item1 = [0, 1], item2 = [1, 1])
    test = PsychometricTest(data, [:item1, :item2], :id)

    @test_throws KeyError personscore(test, 1)
    @test personscore(test, :a) == 1
    @test personscores(test) == [1, 2]
    @test personmean(test, :a) == 0.5
    @test personmeans(test) == [0.5, 1]

    @test_throws KeyError itemscore(test, 2)
    @test itemscore(test, :item1) == 1
    @test itemscores(test) == [1, 2]
    @test itemmean(test, :item1) == 0.5
    @test itemmeans(test) == [0.5, 1]
end
