function split(test::PsychometricTest, ::Colon, is)
    item_ids = getid.(eachitem(test))
    not_is = setdiff(item_ids, is)

    checkids(item_ids, is)
    checkids(item_ids, not_is)

    subtest_1 = construct_split_by_items(test, is)
    subtest_2 = construct_split_by_items(test, not_is)

    return subtest_1, subtest_2
end

function split(test::PsychometricTest, ps, ::Colon)
    person_ids = getid.(eachperson(test))
    not_ps = setdiff(person_ids, ps)

    checkids(person_ids, ps)
    checkids(person_ids, not_ps)

    subtest_1 = construct_split_by_persons(test, ps)
    subtest_2 = construct_split_by_persons(test, not_ps)

    return subtest_1, subtest_2
end

function construct_split_by_items(test::PsychometricTest, is)
    items = filter(x -> getid(x) in is, eachitem(test))
    item_ptr = filter(ptr -> ptr.first in is, test.item_ptr)

    new_properties = (items = items, item_ptr = item_ptr)
    test_split = setproperties(test, new_properties)
    return test_split
end

function construct_split_by_persons(test::PsychometricTest, ps)
    persons = filter(x -> getid(x) in ps, eachperson(test))
    person_ptr = filter(ptr -> ptr.first in ps, test.person_ptr)

    new_properties = (persons = persons, person_ptr = person_ptr)
    test_split = setproperties(test, new_properties)
    return test_split
end

function checkids(ids, is)
    return all(i -> i in ids, is) || throw(ArgumentError("Invalid id variable in $is"))
end