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
getvalue(response::Response) = response.value

"""
    getitemid(response::Response)

Get the unique item id of `response`.
"""
getitemid(response::Response) = response.item_id

"""
    getpersonid(response::Response)

get the unique person id of `response`.
"""
getpersonid(response::Response) = response.person_id

"""
    BasicResponse{IIT,PIT,T}

A minimal implementation of [`Response`](@ref).
Contains an item id `item_id::IIT`, person id `person_id::PIT` and a response value `value::T`.
"""
struct BasicResponse{T} <: Response
    value::T
end
