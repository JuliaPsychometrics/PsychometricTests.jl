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
getid(item::Item) = item.id

"""
    BasicItem{I} <: Item

A minimal implementation of [`Item`](@ref).
Contains no information besides a unique `id` of type `I`.
"""
struct BasicItem{I} <: Item
    id::I
end
