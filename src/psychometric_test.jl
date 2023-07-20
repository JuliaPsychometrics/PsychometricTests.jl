@dim P XDim "Person"
@dim I YDim "Item"

"""
    PsychometricTest{I<:Item,P<:Person,R<:Response,IIT,PIT,ZT}

A struct representing a psychometric test.

## Fields
- `items`: A vector of unique items.
- `persons`: A vector of unique persons.
- `responses`: A vector of responses.
- `item_ptr`: A dictionary of key-value-pairs mapping the unique item identifier to responses.
- `person_ptr`: A dictionary of key-value-pairs mapping the unique person identifier to responses.
- `zeroval`: The zero value for the responses in matrix form (see Details).

## Details
[`PsychometricTest`](@ref) stores the person by item response matrix as a
[coordinate list](https://en.wikipedia.org/wiki/Sparse_matrix#Coordinate_list_(COO)),
allowing for a common data structure for both dense (all persons respond to the same items)
and sparse tests (persons respond to (a subset of) different items, e.g. test equating).
For sparse tests or tests with missing responses, `zeroval` determines the value of the
missing responses when reconstructing the response matrix via [`Matrix`](@ref).

### Construction
At construction item and person pointers are precomputed to allow efficient lookup of
responses for both items and persons.

!!! warning
    It is required that all item ids in `items` as well as person ids in `person` are unique!
    Otherwise an `ArgumentError` is thrown.

"""
struct PsychometricTest{
    Ti<:AbstractVector{<:Item},
    Tp<:AbstractVector{<:Person},
    Tr,
    Ts<:AbstractDict{Symbol,<:Any},
}
    items::Ti
    persons::Tp
    responses::Tr
    scales::Ts
end

function PsychometricTest(m::AbstractMatrix; scales = nothing)
    item_ids = 1:size(m, 2)
    person_ids = 1:size(m, 1)

    items = BasicItem.(item_ids)
    persons = BasicPerson.(person_ids)

    Tr = BasicResponse{eltype(m)}
    responses = DimArray(Tr.(m), (P(person_ids), I(item_ids)))

    if isnothing(scales)
        scales = Dict{Symbol,Any}()
    end

    return PsychometricTest(items, persons, responses, scales)
end

function PsychometricTest(table, item_vars = nothing, id_var = nothing; scales = nothing)
    columns = Tables.columns(table)

    if isnothing(item_vars)
        item_ids = [colname for colname in Tables.columnnames(columns)]
    else
        item_ids = item_vars
    end

    if isnothing(id_var)
        rows = Tables.rows(table)
        person_ids = 1:length(rows)
    else
        person_ids = columns[id_var]
    end

    items = BasicItem.(item_ids)
    persons = BasicPerson.(person_ids)

    Tr = BasicResponse{infer_response_type(columns, item_ids)}
    response_matrix = Matrix{Tr}(undef, length(persons), length(items))

    for (j, item) in enumerate(item_ids)
        col = columns[item]
        response_matrix[:, j] .= Tr.(col)
    end

    if isnothing(scales)
        scales = Dict{Symbol,Any}()
    end

    responses = DimArray(response_matrix, (P(person_ids), I(item_ids)))
    return PsychometricTest(items, persons, responses, scales)
end

function infer_response_type(tbl, item_ids)
    response_types = [eltype(tbl[col]) for col in item_ids]
    return Union{response_types...}
end

getindex(test::PsychometricTest, ps, is) = getindex(test.responses, At(ps), At(is))
getindex(test::PsychometricTest, ps, ::Colon) = getindex(test.responses, At(ps), :)
getindex(test::PsychometricTest, ::Colon, is) = getindex(test.responses, :, At(is))

getitems(test::PsychometricTest) = test.items
getpersons(test::PsychometricTest) = test.persons
getresponses(test::PsychometricTest) = test.responses
getscales(test::PsychometricTest) = test.scales

function getresponses(test::PsychometricTest, scale::Symbol)
    scale_items = test.scales[scale]
    return test.responses[I = At(scale_items)]
end

response_matrix(test::PsychometricTest) = getvalue.(test.responses)

function response_matrix(test::PsychometricTest, scale::Symbol)
    return getvalue.(getresponses(test, scale))
end

function addscale!(test::PsychometricTest, scale::Pair{Symbol,T}) where {T}
    return push!(test.scales, scale)
end

deletescale!(test::PsychometricTest, scale::Symbol) = delete!(test.scales, scale)
