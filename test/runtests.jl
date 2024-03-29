using PsychometricTests
using Test
using Tables
using StatsBase

@testset "PsychometricTests.jl" begin
    include("item.jl")
    include("person.jl")
    include("response.jl")
    include("psychometric_test.jl")
    include("descriptive_statistics.jl")
    include("split.jl")
end
