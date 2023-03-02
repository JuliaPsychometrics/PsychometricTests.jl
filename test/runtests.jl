using PsychometricTests
using Test
using Tables
using StatsBase

@testset "PsychometricTests.jl" begin
    include("item.jl")
    include("person.jl")
    include("response.jl")
    include("test.jl")
    include("descriptives.jl")
end
