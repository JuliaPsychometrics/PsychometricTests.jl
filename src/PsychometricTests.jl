module PsychometricTests

using Tables

import Base: getindex

export PsychometricTest
export Response, BasicResponse, getvalue, getitemid, getpersonid
export Person, BasicPerson
export Item, BasicItem

include("item.jl")
include("person.jl")
include("response.jl")
include("test.jl")

end
