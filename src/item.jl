"""
    Item

An abstract type representing an item in a psychometric test.

Every implementation `T <: Item` must define the following interface:

- [`getid`](@ref): Get the unique item identifier.
"""
abstract type Item end

"""
    getid(item::Item)

Get the unique item identifier of `item`.
"""
function getid(item::Item) end

"""
    BasicItem{I} <: Item

A minimal implementation of [`Item`](@ref).
Contains no information besides a unique `id` of type `I`.
"""
struct BasicItem{I} <: Item
    id::I
end

getid(item::BasicItem) = item.id
