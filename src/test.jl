"""
    PsychometricTest{I<:Item,P<:Person,R<:Response,IIT,PIT,ZT}

A struct representing a psychometric test.

## Fields
- `items`: A vector of unique items.
- `persons`: A vector of unique persons.
- `responses`: A vector of responsese.
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
struct PsychometricTest{I<:Item,P<:Person,R<:Response,IIT,PIT,ZT}
    items::Vector{I}
    persons::Vector{P}
    responses::Vector{R}
    # internals
    item_ptr::Dict{IIT,Vector{Int}}
    person_ptr::Dict{PIT,Vector{Int}}
    zeroval::ZT
    function PsychometricTest(
        items::Vector{I},
        persons::Vector{P},
        responses::Vector{R},
        item_ptr::Dict{IIT,Vector{Int}},
        person_ptr::Dict{PIT,Vector{Int}},
        zeroval::ZT,
    ) where {I,P,R,IIT,PIT,ZT}
        if !allunique(getid.(items))
            throw(ArgumentError("PsychometricTest requires all item ids to be unique"))
        end

        if !allunique(getid.(persons))
            throw(ArgumentError("PsychometricTest requires all person ids to be unique"))
        end

        return new{I,P,R,IIT,PIT,ZT}(
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
    responses::AbstractVector{<:Response},
)
    item_ids = getitemid.(responses)
    person_ids = getpersonid.(responses)

    item_ptr =
        Dict(getid(item) => findall(x -> x == getid(item), item_ids) for item in items)
    person_ptr = Dict(
        getid(person) => findall(x -> x == getid(person), person_ids) for person in persons
    )

    return PsychometricTest(items, persons, responses, item_ptr, person_ptr, nothing)
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
    test::PsychometricTest{I,P,R,IIT,PIT,ZT},
    p::AbstractVector,
    i::AbstractVector,
) where {I,P,R,IIT,PIT,ZT}
    person_responses = [getindex(test, x, :) for x in p]
    responses = reduce(vcat, person_responses)
    filter!(x -> getitemid(x) in i, responses)

    person_map = idmap(getpersonid.(responses))
    item_map = idmap(getitemid.(responses))

    res = Matrix{Union{ZT,R}}(ZT(), length(p), length(i))

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
function Base.Matrix(test::PsychometricTest)
    return getvalue.(test[getid.(test.persons), getid.(test.items)])
end

function Base.show(
    io::IO,
    ::MIME"text/plain",
    test::PsychometricTest{I,P,R,IIT,PIT,ZT},
) where {I,P,R,IIT,PIT,ZT}
    println(
        io,
        "A PsychometricTest with $(nresponses(test)) $R from $(npersons(test)) $P and $(nitems(test)) $I",
    )
    return nothing
end
