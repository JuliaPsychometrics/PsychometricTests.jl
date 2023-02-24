struct PsychometricTest{I<:Item,P<:Person,R<:Response,IIT,PIT,ZT}
    items::Vector{I}
    persons::Vector{P}
    responses::Vector{R}
    # internals
    item_ptr::IdDict{IIT,Vector{Int}}
    person_ptr::IdDict{PIT,Vector{Int}}
    zeroval::ZT
end

function PsychometricTest(
    items::AbstractVector{<:Item},
    persons::AbstractVector{<:Person},
    responses::AbstractVector{<:Response},
)
    item_ids = getitemid.(responses)
    person_ids = getpersonid.(responses)

    item_ptr =
        IdDict(getid(item) => findall(x -> x == getid(item), item_ids) for item in items)
    person_ptr = IdDict(
        getid(person) => findall(x -> x == getid(person), person_ids) for person in persons
    )

    return PsychometricTest(items, persons, responses, item_ptr, person_ptr, nothing)
end

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
            responses[n] = BasicResponse(col, i, value)
        end
    end
    return PsychometricTest(items, persons, responses)
end

function PsychometricTest(data::AbstractMatrix)
    items = 1:size(data, 2)
    return PsychometricTest(Tables.table(data), items)
end

function getindex(test::PsychometricTest, p, ::Colon)
    response_ids = test.person_ptr[p]
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

function idmap(ids::AbstractVector)
    unique_ids = unique(ids)
    return Dict(k => v for (v, k) in enumerate(unique_ids))
end

function Base.Matrix(test::PsychometricTest)
    return getvalue.(test[getid.(test.persons), getid.(test.items)])
end

function Base.show(
    io::IO,
    ::MIME"text/plain",
    test::PsychometricTest{I,P,R,IIT,PIT,ZT},
) where {I,P,R,IIT,PIT,ZT}
    npersons = length(test.persons)
    nitems = length(test.items)
    nresponses = length(test.responses)
    println(
        io,
        "A PsychometricTest with $(nresponses) $R from $(npersons) $P and $(nitems) $I",
    )
    return nothing
end
