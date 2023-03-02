"""
    Person

An abstract type representing a person in a psychometric test.

Every implementation `T <: Person` must define the following interface:

- [`getid`](@ref): Get the unique person identifier.
"""
abstract type Person end

"""
    getid(person::Person)

Get the unique person identifier of `person`.
"""
function getid(person::Person) end

"""
    BasicPerson{I} <: Person

A minimal implementation of [`Person`](@ref).
Contains no information besides a unique `id` of type `I`.
"""
struct BasicPerson{I} <: Person
    id::I
end

getid(person::BasicPerson) = person.id
