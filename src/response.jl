"""
    Response

An abstract type representing a response in a psychometric test.

Every implementation of `T <: Response` must define the following interface:
- [`getvalue`](@ref): Get the response value.
- [`getitemid`](@ref): Get the item id.
- [`getpersonid`](@ref): Get the person id.
"""
abstract type Response end

"""
    getvalue(response::Response)

Get the response value of `response`.
"""
function getvalue(response::Response) end

"""
    getitemid(response::Response)

Get the unique item id of `response`.
"""
function getitemid(response::Response) end

"""
    getpersonid(response::Response)

get the unique person id of `response`.
"""
function getpersonid(response::Response) end

"""
    BasicResponse{IIT,PIT,T}

A minimal implementation of [`Response`](@ref).
Contains an item id `item_id::IIT`, person id `person_id::PIT` and a response value `value::T`.
"""
struct BasicResponse{IIT,PIT,T} <: Response
    item_id::IIT
    person_id::PIT
    value::T
end

getvalue(response::BasicResponse) = response.value
getitemid(response::BasicResponse) = response.item_id
getpersonid(response::BasicResponse) = response.person_id
