@testset "PsychometricTest" begin
    data = rand(0:1, 10, 3)

    @test PsychometricTest(data) isa PsychometricTest
    @test length(PsychometricTest(data).items) == 3
    @test length(PsychometricTest(data).persons) == 10
    @test length(PsychometricTest(data).responses) == 30

    tbl = Tables.table(data)
    @test PsychometricTest(tbl) isa PsychometricTest
    @test length(PsychometricTest(tbl).items) == 3
    @test length(PsychometricTest(tbl).persons) == 10
    @test length(PsychometricTest(tbl).responses) == 30

    t = PsychometricTest(data)
    t[1, :] isa Vector{BasicResponse}
    t[1:5, :] isa Matrix{BasicResponse}
    t[:, 1] isa Vector{BasicResponse}
    t[:, 1:2] isa Matrix{BasicResponse}
end
