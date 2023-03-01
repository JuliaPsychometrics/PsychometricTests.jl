"""
    personscores(test::PsychometricTest)

Calculate the total scores for each person in `test`.
"""
function personscores(test::PsychometricTest)
    return [personscore(test, getid(person)) for person in eachperson(test)]
end

"""
    personscore(test::PsychometricTest, id)

Calculate the total score for person with identifier `id` in `test`.
"""
personscore(test::PsychometricTest, id) = _score(test, id, :)

"""
    itemscores(test::PsychometricTest)

Calculate the total score for each item in `test`.
"""
function itemscores(test::PsychometricTest)
    return [itemscore(test, getid(item)) for item in eachitem(test)]
end

"""
    itemscore(test::PsychometricTest, id)

Calculate the total score for item with identifier `id` in `test`.
"""
itemscore(test::PsychometricTest, id) = _score(test, :, id)

function _score(test::PsychometricTest, pid, iid)
    responses = test[pid, iid]
    score = sum(getvalue(r) for r in responses)
    return score
end

"""
    personmeans(test::PsychometricTest)

Calculate the mean scores for each person in `test`.
"""
function personmeans(test::PsychometricTest)
    return [personmean(test, getid(person)) for person in eachperson(test)]
end

"""
    personmean(test::PsychometricTest, id)

Calculate the mean score for person with identifier `id` in `test`.
"""
personmean(test::PsychometricTest, id) = _mean(test, id, :)

"""
    itemmeans(test::PsychometricTest)

Calculate the mean scores for each item in `test`.
"""
function itemmeans(test::PsychometricTest)
    return [itemmean(test, getid(item)) for item in eachitem(test)]
end

"""
    itemmean(test::PsychometricTest, id)

Calculate the mean score for item with identifier `id` in `test`.
"""
itemmean(test::PsychometricTest, id) = _mean(test, :, id)

function _mean(test::PsychometricTest, pid, iid)
    responses = test[pid, iid]
    avg = mean(getvalue(r) for r in responses)
    return avg
end
