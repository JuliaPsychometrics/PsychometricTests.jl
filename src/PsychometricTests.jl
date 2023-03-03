module PsychometricTests

using StatsBase
using Tables

import Base: getindex

export PsychometricTest
export getitems, getpersons, getresponses
export eachitem, eachperson, eachresponse
export nitems, npersons, nresponses

export Response, BasicResponse, getvalue, getitemid, getpersonid
export Person, BasicPerson
export Item, BasicItem
export getid

export personscores, personscore, personmeans, personmean
export itemscores, itemscore, itemmeans, itemmean

include("item.jl")
include("person.jl")
include("response.jl")
include("test.jl")

include("descriptives.jl")

end
