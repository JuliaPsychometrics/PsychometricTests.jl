module PsychometricTests

using Accessors
using StatsBase
using Tables
using ThreadsX
using DimensionalData
using .LookupArrays
using DimensionalData: @dim, XDim, YDim
using LinearAlgebra
using LazyArrays

using StatsBase: cov2cor!

import Base: getindex, split

export PsychometricTest
export getitems, getpersons, getresponses
export eachitem, eachperson, eachresponse
export nitems, npersons, nresponses
export additems!, addpersons!, addresponses!
export invalidate!

export Response, BasicResponse, getvalue, getitemid, getpersonid
export Person, BasicPerson
export Item, BasicItem
export getid

export personscores, personscore, personmeans, personmean, personcov, personcor
export itemscores, itemscore, itemmeans, itemmean, itemcov, itemcor
export subset, split
export response_matrix

# tmp
export P, I

include("item.jl")
include("person.jl")
include("response.jl")
include("psychometric_test.jl")

include("descriptive_statistics.jl")
include("split.jl")

# include("precompile.jl")

end
