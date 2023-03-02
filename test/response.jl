@testset "Response" begin
    response = BasicResponse(1, 2, 3)
    @test getitemid(response) == 1
    @test getpersonid(response) == 2
    @test getvalue(response) == 3
end
