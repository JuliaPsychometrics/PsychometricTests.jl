function split(test::PsychometricTest, ::Colon, is; check_args = true)
    item_ids = getid.(eachitem(test))
    check_args && checkids(item_ids, is)

    not_is = setdiff(item_ids, is)

    subtest_1 = subset(test, :, is)
    subtest_2 = subset(test, :, not_is)

    return subtest_1, subtest_2
end

function split(test::PsychometricTest, ps, ::Colon; check_args = true)
    person_ids = getid.(eachperson(test))
    check_args && checkids(person_ids, ps)

    not_ps = setdiff(person_ids, ps)

    subtest_1 = subset(test, ps, :)
    subtest_2 = subset(test, not_ps, :)

    return subtest_1, subtest_2
end

function subset(test::PsychometricTest, ps, is; check_args = true)
    if check_args
        checkids(getid.(eachperson(test)), ps)
        checkids(getid.(eachitem(test)), is)
    end

    persons = filter(x -> getid(x) in ps, eachperson(test))
    items = filter(x -> getid(x) in is, eachitem(test))
    responses = filter(x -> getpersonid(x) in ps && getitemid(x) in is, eachresponse(test))

    return PsychometricTest(items, persons, responses)
end

function subset(test::PsychometricTest, ::Colon, is; check_args = true)
    check_args && checkids(getid.(eachitem(test)), is)

    items = filter(x -> getid(x) in is, eachitem(test))
    responses = filter(x -> getitemid(x) in is, eachresponse(test))

    subtest = PsychometricTest(items, getpersons(test), responses)
    return subtest
end

function subset(test::PsychometricTest, ps, ::Colon; check_args = true)
    check_args && checkids(getid.(eachperson(test)), ps)

    persons = filter(x -> getid(x) in ps, eachperson(test))
    responses = filter(x -> getpersonid(x) in ps, eachresponse(test))

    subtest = PsychometricTest(getitems(test), persons, responses)
    return subtest
end

function checkids(ids, is)
    return all(i -> i in ids, is) || throw(ArgumentError("Invalid id variable in $is"))
end
