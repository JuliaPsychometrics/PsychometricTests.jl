function split(test::PsychometricTest, ps, ::Colon)
    person_ids = getid.(test.persons)
    not_ps = setdiff(person_ids, ps)

    subtest_1 = subset(test, ps, :)
    subtest_2 = subset(test, not_ps, :)

    return subtest_1, subtest_2
end

function split(test::PsychometricTest, ::Colon, is)
    item_ids = getid.(test.items)
    not_is = setdiff(item_ids, is)

    subtest_1 = subset(test, is, :)
    subtest_2 = subset(test, not_is, :)

    return subtest_1, subtest_2
end

function subset(test::PsychometricTest, ps, is)
    items = filter(x -> getid(x) in is, test.items)
    persons = filter(x -> getid(x) in ps, test.persons)
    responses = test[ps, is]
    return PsychometricTest(items, persons, responses)
end

function subset(test::PsychometricTest, ps, ::Colon)
    return subset(test, ps, getid.(test.items))
end

function subset(test::PsychometricTest, ::Colon, is)
    return subset(test, getid.(test.persons), is)
end
