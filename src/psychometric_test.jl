@dim P XDim "Person"
@dim I YDim "Item"

"""
    PsychometricTest{Ti,Tp,Tr,Ts}

A struct representing a psychometric test.
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

"""
    PsychometricTest(m::AbstractMatrix; scales = nothing)

Construct a `PsychometricTest` from a response matrix `m`.

```jldoctest
julia> m = ones(Int, 10, 2);

julia> PsychometricTest(m);
```

"""
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

response_matrix(responses::AbstractArray{<:Response}) = getvalue.(responses)
response_matrix(test::PsychometricTest) = response_matrix(test.responses)

function response_matrix(test::PsychometricTest, scale::Symbol)
    scale_items = test.scales[scale]
    responses = getresponses(test)
    response_values = getvalue.(view(responses, :, scale_items))
    return response_values
end

function addscale!(test::PsychometricTest, scale::Pair{Symbol,T}) where {T}
    return push!(test.scales, scale)
end

deletescale!(test::PsychometricTest, scale::Symbol) = delete!(test.scales, scale)

function Base.show(io::IO, test::PsychometricTest{Ti,Tp,Tr,Ts}) where {Ti,Tp,Tr,Ts}
    npersons = format(length(getpersons(test)), commas = true)
    nitems = format(length(getitems(test)), commas = true)
    nresponses = format(length(getresponses(test)), commas = true)

    persontype = eltype(Tp)
    itemtype = eltype(Ti)
    responsetype = eltype(Tr)


    baseinfo_panel = Term.Panel(
        "persons: {magenta}$(npersons){/magenta} {dim}(type: $persontype)",
        "items: {magenta}$(nitems){/magenta} {dim}(type: $itemtype)",
        "responses: {magenta}$(nresponses){/magenta} {dim}(type: $responsetype)",
        title = "base info",
        width = 60,
    )

    types_panel = Term.Panel(
        "$(typeformat(fieldtype(persontype, :id)))",
        "$(typeformat(fieldtype(itemtype, :id)))",
        "",
        title = "index",
        width = 18,
        justify = :center,
    )

    scales = getscales(test)

    if length(scales) > 0
        scale_panel_content = (
            Term.Table(
                Dict(:index => collect(keys(scales)), :items => collect(values(scales))),
                box = :SIMPLE,
                columns_justify = :left,
                columns_style = ["bold yellow", "default"],
            ),
            "{dim}Hint: Use deletescale! to remove scales from the test.",
        )
    else
        scale_panel_content = "{dim}This PsychometricTest does not contain any scales yet.{/dim}\n{dim}Use {cyan}addscale!{/cyan} to add new scales to the test.{/dim}"
    end


    scales_panel = Term.Panel(
        scale_panel_content,
        title = "{green}scales",
        width = 78,
        style = "green",
    )

    print(
        io,
        Term.Panel(
            baseinfo_panel * types_panel / scales_panel,
            title = "{dim}PsychometricTest",
            width = 84,
            style = "dim",
            subtitle = "{dim}PsychometricTests.jl",
            subtitle_justify = :right,
        ),
    )

    return nothing
end

function typeformat(x)
    if x <: Number
        return "{cyan}::$x{/cyan}"
    elseif x <: AbstractString
        return "{yellow}::$x{/yellow}"
    elseif x <: Symbol
        return "{blue}::$x{/blue}"
    else
        return "$x"
    end
end

