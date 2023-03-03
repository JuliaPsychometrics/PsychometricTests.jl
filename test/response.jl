@testset "Response" begin
    ids = [1, :a, "b"]

    for item_id in ids
        for person_id in ids
            response = BasicResponse(item_id, person_id, 1)
            @test getitemid(response) == item_id
            @test getpersonid(response) == person_id
            @test getvalue(response) == 1
        end
    end
end
