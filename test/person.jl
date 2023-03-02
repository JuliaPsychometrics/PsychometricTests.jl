@testset "Person" begin
    person = BasicPerson(1)
    @test getid(person) == 1

    person = BasicPerson(:P1)
    @test getid(person) == :P1

    person = BasicPerson("P1")
    @test getid(person) == "P1"
end
