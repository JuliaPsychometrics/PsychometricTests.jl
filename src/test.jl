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
    Tr<:AbstractVector{<:Response},
    Tiid,
    Tpid,
    Tz,
}
    items::Ti
    persons::Tp
    responses::Tr
    # internals
    item_ptr::Dict{Tiid,Vector{Int}}
    person_ptr::Dict{Tpid,Vector{Int}}
    zeroval::Tz
    function PsychometricTest(
        items::Ti,
        persons::Tp,
        responses::Tr,
        item_ptr::Dict{Tiid,Vector{Int}},
        person_ptr::Dict{Tpid,Vector{Int}},
        zeroval::Tz;
        check_args = false,
    ) where {Ti,Tp,Tr,Tiid,Tpid,Tz}
        if check_args
            if !allunique(getid.(items))
                throw(ArgumentError("PsychometricTest requires all item ids to be unique"))
            end

            if !allunique(getid.(persons))
                throw(
                    ArgumentError("PsychometricTest requires all person ids to be unique"),
                )
            end
        end

        return new{Ti,Tp,Tr,Tiid,Tpid,Tz}(
            items,
            persons,
            responses,
            item_ptr,
            person_ptr,
            zeroval,
        )
    end
end

"""
    PsychometricTest(items, persons, responses)

Construct a psychometric test from a vector of `items`, a vector of `persons`, and a vector
of `responses`.

!!! warning
    It is required that all item ids in `items` as well as person ids in `person` are unique!
    Otherwise an `ArgumentError` is thrown.

# Examples
```jldoctest
julia> items = [BasicItem(i) for i in 1:3];

julia> persons = [BasicPerson(p) for p in 1:2];

julia> responses = vec([BasicResponse(i, p, rand(0:1)) for i in 1:3, p in 1:2]);

julia> test = PsychometricTest(items, persons, responses)
A PsychometricTest with 6 BasicResponse{Int64, Int64, Int64} from 2 BasicPerson{Int64} and 3 BasicItem{Int64}

```
"""
function PsychometricTest(
    items::AbstractVector{<:Item},
    persons::AbstractVector{<:Person},
    responses::AbstractVector{<:Response};
    check_args = true,
)
    item_ids = getitemid.(responses)
    person_ids = getpersonid.(responses)

    item_ptr = create_ptr(items, item_ids)
    person_ptr = create_ptr(persons, person_ids)

    return PsychometricTest(
        items,
        persons,
        responses,
        item_ptr,
        person_ptr,
        missing;
        check_args,
    )
end

function create_ptr(arr, ref)
    asd = ThreadsX.map(arr) do x
        id = getid(x)
        return Pair(id, findall(x -> x == id, ref))
    end
    return Dict(asd)
end

"""
    PsychometricTest(table, item_vars = Tables.columnnames(table), id_var = nothing)

Construct a psychometric test from a [Tables.jl](https://tables.juliadata.org/stable/)
compatible `table`.

If only a column subset of `table` is to be included in the resulting test, specify a vector
of column names in `item_vars`. The unique item identifier then corresponds to the column
name of the table.

`id_var` is used to determine the unique person identificators.
If `id_var = nothing` (the default), the person id is an integer index corresponding to the
table row.

## Examples
### From `DataFrame` with default settings
```jldoctest
julia> using DataFrames

julia> response_data = DataFrame(Item1 = [1, 0, 1], Item2 = [0, 0, 1]);

julia> test = PsychometricTest(response_data)
A PsychometricTest with 6 BasicResponse{Symbol, Int64, Int64} from 3 BasicPerson{Int64} and 2 BasicItem{Symbol}

```

### From a subset of a `DataFrame`
```jldoctest
julia> using DataFrames

julia> response_data = DataFrame(Item1 = [1, 0, 1], Item2 = [0, 0, 1], Item3 = [1, 1, 1]);

julia> test = PsychometricTest(response_data, [:Item1, :Item3])
A PsychometricTest with 6 BasicResponse{Symbol, Int64, Int64} from 3 BasicPerson{Int64} and 2 BasicItem{Symbol}

```

### From a `DataFrame` with custom id variable
```jldoctest
julia> using DataFrames

julia> response_data = DataFrame(id = [:a, :b, :c], Item1 = [1, 0, 1], Item2 = [0, 0, 1]);

julia> test = PsychometricTest(response_data, [:Item1, :Item2], :id)
A PsychometricTest with 6 BasicResponse{Symbol, Symbol, Int64} from 3 BasicPerson{Symbol} and 2 BasicItem{Symbol}

```

"""
function PsychometricTest(table, item_vars = Tables.columnnames(table), id_var = nothing)
    columns = Tables.columns(table)

    if isnothing(id_var)
        rows = Tables.rows(table)
        person_ids = 1:length(rows)
    else
        person_ids = columns[id_var]
    end

    items = [BasicItem(item) for item in item_vars]
    persons = [BasicPerson(person) for person in person_ids]

    ResponseType = BasicResponse{
        eltype(item_vars),
        eltype(person_ids),
        eltype(columns[first(item_vars)]),
    }

    responses = Vector{ResponseType}(undef, length(items) * length(persons))

    n = 0
    for col in item_vars
        for (i, value) in enumerate(columns[col])
            n += 1
            responses[n] = BasicResponse(col, person_ids[i], value)
        end
    end
    return PsychometricTest(items, persons, responses)
end

"""
    PsychometricTest(data::AbstractMatrix)

Construct a psychometric test from a response matrix.

Id variables for persons and items are derived from the row number and column number
respectively.

## Examples
```jldoctest
julia> response_data = rand(0:1, 5, 3);

julia> test = PsychometricTest(response_data)
A PsychometricTest with 15 BasicResponse{Int64, Int64, Int64} from 5 BasicPerson{Int64} and 3 BasicItem{Int64}

```
"""
function PsychometricTest(data::AbstractMatrix)
    items = 1:size(data, 2)
    return PsychometricTest(Tables.table(data), items)
end

function getindex(test::PsychometricTest, p, ::Colon)
    response_ids = getindex(test.person_ptr, p)
    return view(test.responses, response_ids)
end

function getindex(test::PsychometricTest, ::Colon, i)
    response_ids = test.item_ptr[i]
    return view(test.responses, response_ids)
end

function getindex(
    test::PsychometricTest{Ti,Tp,Tr,Tiid,Tpid,Tz},
    p::AbstractVector,
    i::AbstractVector,
) where {Ti,Tp,Tr,Tiid,Tpid,Tz}
    person_responses = [getindex(test, x, :) for x in p]
    responses = reduce(vcat, person_responses)
    filter!(x -> getitemid(x) in i, responses)

    person_map = idmap(getpersonid.(responses))
    item_map = idmap(getitemid.(responses))

    res = Matrix{Union{Tz,eltype(Tr)}}(Tz(), length(p), length(i))

    for r in responses
        person_pos = person_map[getpersonid(r)]
        item_pos = item_map[getitemid(r)]
        res[person_pos, item_pos] = r
    end

    return res
end

getindex(test::PsychometricTest, p::AbstractVector, ::Colon) = test[p, getid.(test.items)]
getindex(test::PsychometricTest, ::Colon, i::AbstractVector) = test[getid.(test.persons), i]

function getindex(test::PsychometricTest, ::Colon, ::Colon)
    return test[getid.(test.persons), getid.(test.items)]
end

function idmap(ids::AbstractVector)
    unique_ids = unique(ids)
    return Dict(k => v for (v, k) in enumerate(unique_ids))
end

"""
    getitems(test::PsychometricTest)

Get the vector of items of a psychometric test.

## Examples
```jldoctest
julia> data = rand(0:1, 3, 2);

julia> test = PsychometricTest(data);

julia> getitems(test)
2-element Vector{BasicItem{Int64}}:
 BasicItem{Int64}(1)
 BasicItem{Int64}(2)

```
"""
getitems(test::PsychometricTest) = test.items

"""
    getpersons(test::PsychometricTest)

Get the vector of persons of a psychometric test.

## Examples
```jldoctest
julia> data = rand(0:1, 3, 2);

julia> test = PsychometricTest(data);

julia> getpersons(test)
3-element Vector{BasicPerson{Int64}}:
 BasicPerson{Int64}(1)
 BasicPerson{Int64}(2)
 BasicPerson{Int64}(3)

```
"""
getpersons(test::PsychometricTest) = test.persons

"""
    getresponses(test::PsychometricTest)

Get the vector of responses of a psychometric test.

## Examples
```jldoctest
julia> data = [0 0 1; 1 0 1];

julia> test = PsychometricTest(data);

julia> getresponses(test)
6-element Vector{BasicResponse{Int64, Int64, Int64}}:
 BasicResponse{Int64, Int64, Int64}(1, 1, 0)
 BasicResponse{Int64, Int64, Int64}(1, 2, 1)
 BasicResponse{Int64, Int64, Int64}(2, 1, 0)
 BasicResponse{Int64, Int64, Int64}(2, 2, 0)
 BasicResponse{Int64, Int64, Int64}(3, 1, 1)
 BasicResponse{Int64, Int64, Int64}(3, 2, 1)

```
"""
getresponses(test::PsychometricTest) = test.responses

"""
    eachitem(test::PsychometricTest)

Iterate over each item in `test`.
"""
eachitem(test::PsychometricTest) = getitems(test)

"""
    eachperson(test::PsychometricTest)

Iterate over each person in `test`.
"""
eachperson(test::PsychometricTest) = getpersons(test)

"""
    eachresponse(test::PsychometricTest)

Iterate over each response in `test`.
"""
eachresponse(test::PsychometricTest) = getresponses(test)

"""
    nitems(test::PsychometricTest)

Get the number of items in `test`.
"""
nitems(test::PsychometricTest) = length(getitems(test))

"""
    npersons(test::PsychometricTest)

Get the number of persons in `test`.
"""
npersons(test::PsychometricTest) = length(getpersons(test))

"""
    nresponses(test::PsychometricTest)

Get the number of responses in `test`.
"""
nresponses(test::PsychometricTest) = length(getresponses(test))

"""
    additems!(test::PsychometricTest, items::AbstractVector{<:Item})
    additems!(test::PsychometricTest, items::Item)

Add one or multiple new items to `test`.
"""
function additems!(test::PsychometricTest, items::AbstractVector{<:Item})
    item_ids = getid.(getitems(test))
    new_item_ids = getid.(items)

    duplicate_items = [id ∈ item_ids for id in new_item_ids]
    if any(duplicate_items)
        duplicate_ids = new_item_ids[duplicate_items]
        throw(ArgumentError("Item(s) with id already exists: $(duplicate_ids)"))
    end

    return append!(test.items, items)
end

additems!(test::PsychometricTest, items::Item) = additems!(test, [items])

"""
    addpersons!(test::PsychometricTest, persons::AbstractVector{<:Person})
    addpersons!(test::PsychometricTest, persons::Person)

Add one or multiple new persons to `test`.
"""
function addpersons!(test::PsychometricTest, persons::AbstractVector{<:Person})
    person_ids = getid.(getpersons(test))
    new_person_ids = getid.(persons)

    duplicate_persons = [id in person_ids for id in new_person_ids]
    if any(duplicate_persons)
        duplicate_ids = new_person_ids[duplicate_persons]
        throw(ArgumentError("Person(s) with id already exists: $(duplicate_ids)"))
    end

    return append!(test.persons, persons)
end

addpersons!(test::PsychometricTest, persons::Person) = addpersons!(test, [persons])

"""
    addresponses!(test::PsychometricTest, responses; force = false, invalidate = true)

## Keyword arguments
- `force`: Overwrite responses if they already exist (default: false)
- `invalidate`: Recalculate the internal pointers for items and persons (default: true)

!!! warning
    Setting `invalidate = false` will lead to undefined behaviour of subsequent lookups.
    Use this setting only at your own risk and in conjunction with manual invalidation.
    See also [`invalidate!`](@ref).
"""
function addresponses!(
    test::PsychometricTest,
    responses::AbstractVector{<:Response};
    force = false,
    invalidate = true,
)
    # check item ids
    invalid_item_ids = Int[]
    invalid_person_ids = Int[]
    invalid_response_ids = Int[]

    person_ids = getid.(test.persons)
    item_ids = getid.(test.items)

    for (i, response) in enumerate(responses)
        if !(getitemid(response) in item_ids)
            push!(invalid_item_ids, i)
        end

        if !(getpersonid(response) in person_ids)
            push!(invalid_person_ids, i)
        end

        if responsealreadyexists(test, response)
            push!(invalid_response_ids, i)
        end
    end

    if length(invalid_item_ids) > 0
        throw(ArgumentError("Invalid item ids: $(getitemid.(responses[invalid_item_ids]))"))
    end

    if length(invalid_person_ids) > 0
        throw(
            ArgumentError(
                "Invalid person ids: $(getpersonid.(responses[invalid_person_ids]))",
            ),
        )
    end

    if length(invalid_response_ids) > 0
        if force
            # delete duplicate responses
            # new responses will be reinserted with non-duplicates
            deleteat!(test.responses, invalid_response_ids)
        else
            throw(ArgumentError("Response already exists: $(invalid_response_ids)"))
        end
    end

    new_responses = append!(test.responses, responses)

    invalidate && invalidate!(test)

    return new_responses
end

function addresponses!(test::PsychometricTest, responses::Response; kwargs...)
    return addresponses!(test, [responses]; kwargs...)
end

function responsealreadyexists(test, response)
    for r in eachresponse(test)
        itemid_equal = getitemid(r) == getitemid(response)
        personid_equal = getpersonid(r) == getpersonid(response)
        if itemid_equal && personid_equal
            return true
        end
    end
    return false
end

"""
    invalidate!(test::PsychometricTest)

Invalidate and recalculate the pointers for items and persons in `test`.
"""
function invalidate!(test::PsychometricTest)
    responses = getresponses(test)
    item_ids = getitemid.(responses)
    person_ids = getpersonid.(responses)

    for item in eachitem(test)
        invalidate_ptr!(test.item_ptr, getid(item), item_ids, person_ids)
    end

    for person in eachperson(test)
        invalidate_ptr!(test.person_ptr, getid(person), person_ids, item_ids)
    end

    return nothing
end

function invalidate_ptr!(ptr, k, ids, order)
    response_ids = findall(x -> x == k, ids)
    sort_order = sortperm(order[response_ids])
    ptr[k] = response_ids[sort_order]
    return nothing
end

"""
    Matrix(test::PsychometricTest)

Get the person by item response matrix from `test`.

## Examples
```jldoctest
julia> response_data = [0 1 0; 1 0 0; 0 0 1];

julia> test = PsychometricTest(response_data);

julia> Matrix(test)
3×3 Matrix{Int64}:
 0  1  0
 1  0  0
 0  0  1

julia> Matrix(test) == response_data
true

```
"""
function Base.Matrix(
    test::PsychometricTest{Ti,Tp,Tr,Tiid,Tpid,Tz},
) where {Ti,Tp,Tr,Tiid,Tpid,Tz}
    response_matrix = test[:, :]

    response_type = fieldtype(eltype(Tr), :value)
    output_type = haszeros(test) ? Union{Tz,response_type} : response_type
    output_matrix = similar(response_matrix, output_type)

    for i in eachindex(response_matrix)
        if response_matrix[i] isa Tz
            output_matrix[i] = test.zeroval
        else
            output_matrix[i] = getvalue(response_matrix[i])
        end
    end
    return output_matrix
end

haszeros(test::PsychometricTest) = any(test[:, :] .=== test.zeroval)

function Base.show(io::IO, ::MIME"text/plain", test::PsychometricTest)
    item_type = eltype(test.items)
    response_type = eltype(test.responses)
    person_type = eltype(test.persons)

    println(
        io,
        "A PsychometricTest with $(nresponses(test)) $response_type from $(npersons(test)) $person_type and $(nitems(test)) $item_type",
    )
    return nothing
end
