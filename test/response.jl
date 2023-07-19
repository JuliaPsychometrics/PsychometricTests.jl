@testset "Response" begin
    @test getvalue(BasicResponse(1)) == 1
    @test getvalue(BasicResponse("A")) == "A"
    @test getvalue(BasicResponse(0.5)) == 0.5
end
