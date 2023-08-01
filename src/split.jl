"""
    split(test::PsychometricTest, ps, :; view = false)
    split(test::PsychometricTest, :, is; view = false)

Split a psychometric test by item or person indices.
`split` returns a tuple of psychometric tests where the first test contains data for indices
provided by `ps` or `is`, and the second test contains data for indices `!ps` or `!is` respectively.

If `view = false` (the default), copies of `test` are returned.
If `view = true`, views into the original `test` are returned.
This can improve performance for cases where data does not need to be modified.

If only a single subtest is needed, see also [`subset`](@ref).
"""
function Base.split(test::PsychometricTest, ps, ::Colon; view::Bool = false)
    person_ids = getid.(getpersons(test))
    not_ps = setdiff(person_ids, ps)

    subtest_1 = subset(test, ps, :; view)
    subtest_2 = subset(test, not_ps, :; view)

    return subtest_1, subtest_2
end

function Base.split(test::PsychometricTest, ::Colon, is; view::Bool = false)
    item_ids = getid.(getitems(test))
    not_is = setdiff(item_ids, is)

    subtest_1 = subset(test, :, is; view)
    subtest_2 = subset(test, :, not_is; view)

    return subtest_1, subtest_2
end

"""
    subset(test::PsychometricTest, ps, is; view = false)

Return a psychometric test that is a subset of `test`.
The resulting subtest will contain responses for persons and items provided by indices `ps`
and `is` respectively.

If `view = false` (the default), copies of `test` are returned.
If `view = true`, views into the original `test` are returned.
This can improve performance for cases where data does not need to be modified.
"""
function subset(test::PsychometricTest, ps, is; view::Bool = false)
    if view
        _subset_view(test, ps, is)
    else
        _subset_copy(test, ps, is)
    end
end

function subset(test::PsychometricTest, ps, ::Colon; view::Bool = false)
    if view
        _subset_view(test, ps, getid.(getitems(test)))
    else
        _subset_copy(test, ps, getid.(getitems(test)))
    end
end

function subset(test::PsychometricTest, ::Colon, is; view::Bool = false)
    if view
        _subset_view(test, getid.(getpersons(test)), is)
    else
        _subset_copy(test, getid.(getpersons(test)), is)
    end
end

function _subset_copy(test::PsychometricTest, ps, is)
    items = filter(x -> getid(x) in is, test.items)
    persons = filter(x -> getid(x) in ps, test.persons)
    responses = test[ps, is]

    scales = copy(getscales(test))
    filter!(x -> all(in.(x[2], Ref(is))), scales)

    return PsychometricTest(items, persons, responses, scales)
end

function _subset_view(test::PsychometricTest, ps, is)
    items = @view test.items[findall(x -> getid(x) in is, test.items)]
    persons = @view test.persons[findall(x -> getid(x) in ps, test.persons)]
    responses = @view test.responses[P = At(ps), I = At(is)]

    scales = copy(getscales(test))
    filter!(x -> all(in.(x[2], Ref(is))), scales)

    return PsychometricTest(items, persons, responses, scales)
end

