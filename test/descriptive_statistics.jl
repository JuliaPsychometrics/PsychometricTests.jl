@testset "Descriptive statistics" begin
    data = rand(0:1, 100, 10)
    scales = Dict(:s1 => 1:2, :s2 => [3])
    t = PsychometricTest(data; scales)

    @test personscores(t) == sum(data, dims = 2)
    @test personscores(t, :s1) == sum(data[:, scales[:s1]], dims = 2)
    @test personscores(t, :s2) == sum(data[:, scales[:s2]], dims = 2)

    @test personscore(t, 1) == sum(data[1, :])
    @test personscore(t, 1, :s1) == sum(data[1, scales[:s1]])
    @test personscore(t, 1, :s2) == sum(data[1, scales[:s2]])

    @test itemscores(t) == sum(data, dims = 1)
    @test itemscores(t, :s1) == sum(data[:, scales[:s1]], dims = 1)
    @test itemscores(t, :s2) == sum(data[:, scales[:s2]], dims = 1)

    @test itemscore(t, 1) == sum(data[:, 1])
    @test itemscore(t, 2) == sum(data[:, 2])
    @test itemscore(t, 3) == sum(data[:, 3])

    @test personmeans(t) == mean(data, dims = 2)
    @test personmeans(t, :s1) == mean(data[:, scales[:s1]], dims = 2)
    @test personmeans(t, :s2) == mean(data[:, scales[:s2]], dims = 2)

    @test personmean(t, 1) == mean(data[1, :])
    @test personmean(t, 1, :s1) == mean(data[1, scales[:s1]])
    @test personmean(t, 1, :s2) == mean(data[1, scales[:s2]])

    @test itemmeans(t) == mean(data, dims = 1)
    @test itemmeans(t, :s1) == mean(data[:, scales[:s1]], dims = 1)
    @test itemmeans(t, :s2) == mean(data[:, scales[:s2]], dims = 1)

    @test itemmean(t, 1) == mean(data[:, 1])
    @test itemmean(t, 2) == mean(data[:, 2])
    @test itemmean(t, 3) == mean(data[:, 3])

    @test itemcov(t) ≈ cov(data, dims = 1)
    @test itemcov(t, corrected = false) ≈ cov(data, dims = 1, corrected = false)
    @test itemcor(t) ≈ cor(data, dims = 1)

    @test personcov(t) ≈ cov(data, dims = 2)
    @test personcov(t, corrected = false) ≈ cov(data, dims = 2, corrected = false)
    @test personcor(t) ≈ cor(data, dims = 2)

    # symbol based indexing
    data = (; id = [:a, :b], item1 = [0, 1], item2 = [1, 1])
    test = PsychometricTest(data, [:item1, :item2], :id)

    @test_throws ArgumentError personscore(test, 1)
    @test_throws ArgumentError itemscore(test, 2)

    @test personscore(test, :a) == 1
    @test personmean(test, :a) == 0.5
    @test itemscore(test, :item1) == 1
    @test itemmean(test, :item1) == 0.5
end
