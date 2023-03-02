@testset "Item" begin
    item = BasicItem(1)
    @test getid(item) == 1

    item = BasicItem(:Item1)
    @test getid(item) == :Item1

    item = BasicItem("Item1")
    @test getid(item) == "Item1"
end
