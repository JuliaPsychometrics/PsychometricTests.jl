"""
    personscores(test::PsychometricTest)

Calculate the total scores for each person in `test`.
"""
function personscores(test::PsychometricTest)
    values = getvalue.(test.responses)
    scores = sum(values, dims = I)
    return scores
end

"""
    personscore(test::PsychometricTest, id)

Calculate the total score for person with identifier `id` in `test`.
"""
function personscore(test::PsychometricTest, id)
    values = getvalue.(test.responses[P = At(id)])
    scores = sum(values)
    return scores
end

"""
    itemscores(test::PsychometricTest)

Calculate the total score for each item in `test`.
"""
function itemscores(test::PsychometricTest)
    values = getvalue.(test.responses)
    scores = sum(test.responses, dims = P)
    return scores
end



"""
    itemscore(test::PsychometricTest, id)

Calculate the total score for item with identifier `id` in `test`.
"""
itemscore(test::PsychometricTest, id) = sum(getvalue, test.responses[I = At(id)])

"""
    personmeans(test::PsychometricTest)

Calculate the mean scores for each person in `test`.
"""
personmeans(test::PsychometricTest) = mean(getvalue, test.responses, dims = I)

"""
    personmean(test::PsychometricTest, id)

Calculate the mean score for person with identifier `id` in `test`.
"""
personmean(test::PsychometricTest, id) = mean(getvalue, test.responses[P = At(id)])

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
