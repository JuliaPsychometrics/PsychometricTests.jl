"""
    Response

An abstract type representing a response in a psychometric test.

Every implementation of `T <: Response` must define the following interface:
- [`getvalue`](@ref): Get the response value.
"""
abstract type Response end

"""
    getvalue(response::Response)

Get the response value of `response`.
"""
getvalue(response) = response
getvalue(response::Response) = response.value

"""
    BasicResponse{T}

A minimal implementation of [`Response`](@ref).
Contains a response value `value::T`.
"""
struct BasicResponse{T} <: Response
    value::T
end
