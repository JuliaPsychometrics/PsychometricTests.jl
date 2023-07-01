module PsychometricTests

using Accessors
using StatsBase
using Tables
using ThreadsX

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

export personscores, personscore, personmeans, personmean
export itemscores, itemscore, itemmeans, itemmean
export subset, split

include("item.jl")
include("person.jl")
include("response.jl")
include("psychometric_test.jl")

include("descriptives.jl")
include("split.jl")

include("precompile.jl")

end
