"""
    split(test::PsychometricTest, ps, :)
    split(test::PsychometricTest, :, is)

Split a psychometric test by item or person indices.
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
    return PsychometricTest(items, persons, responses)
end

function _subset_view(test::PsychometricTest, ps, is)
    items = @view test.items[findall(x -> getid(x) in is, test.items)]
    persons = @view test.persons[findall(x -> getid(x) in ps, test.persons)]
    responses = @view test.responses[P = At(ps), I = At(is)]
    return PsychometricTest(items, persons, responses)
end

