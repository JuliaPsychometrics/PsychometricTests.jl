module PsychometricTests

using DimensionalData
using DimensionalData: @dim, XDim, YDim
using .LookupArrays
using LinearAlgebra
using StatsBase
using Tables
using Format
import Term

using StatsBase: cov2cor!

import Base: getindex, split

export PsychometricTest
export getitems, getpersons, getresponses, getscales
export response_matrix
export addscale!, deletescale!

export Response, BasicResponse, getvalue
export Person, BasicPerson
export Item, BasicItem
export getid

export personscores, personscore, personmeans, personmean, personcov, personcor
export itemscores, itemscore, itemmeans, itemmean, itemcov, itemcor
export subset, split

include("item.jl")
include("person.jl")
include("response.jl")
include("psychometric_test.jl")

include("descriptive_statistics.jl")
include("split.jl")

include("precompile.jl")

end
