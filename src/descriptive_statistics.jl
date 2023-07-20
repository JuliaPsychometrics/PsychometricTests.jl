"""
    personscores(test::PsychometricTest)

Calculate the total scores for each person in `test`.
"""
function personscores(test::PsychometricTest)
    responses = getresponses(test)
    scores = sum(getvalue, responses, dims = I)
    return scores
end

function personscores(test::PsychometricTest, scale::Symbol)
    responses = getresponses(test, scale)
    scores = sum(getvalue, responses, dims = I)
    return scores
end

"""
    personscore(test::PsychometricTest, id)

Calculate the total score for person with identifier `id` in `test`.
"""
function personscore(test::PsychometricTest, id)
    responses = test[id, :]
    scores = sum(getvalue, responses)
    return scores
end

function personscore(test::PsychometricTest, id, scale::Symbol)
    responses = getresponses(test, scale)[P = At(id)]
    scores = sum(getvalue, responses)
    return scores
end

"""
    itemscores(test::PsychometricTest)

Calculate the total score for each item in `test`.
"""
function itemscores(test::PsychometricTest)
    responses = getresponses(test)
    scores = sum(getvalue, responses, dims = P)
    return scores
end

function itemscores(test::PsychometricTest, scale::Symbol)
    responses = getresponses(test, scale)
    scores = sum(getvalue, responses, dims = P)
    return scores
end

"""
    itemscore(test::PsychometricTest, id)

Calculate the total score for item with identifier `id` in `test`.
"""
function itemscore(test::PsychometricTest, id)
    responses = test[:, id]
    scores = sum(getvalue, responses)
    return scores
end

"""
    personmeans(test::PsychometricTest)

Calculate the mean scores for each person in `test`.
"""
function personmeans(test::PsychometricTest)
    responses = getresponses(test)
    average = mean(getvalue, responses, dims = I)
    return average
end

function personmeans(test::PsychometricTest, scale::Symbol)
    responses = getresponses(test, scale)
    average = mean(getvalue, responses, dims = I)
    return average
end

"""
    personmean(test::PsychometricTest, id)

Calculate the mean score for person with identifier `id` in `test`.
"""
function personmean(test::PsychometricTest, id)
    responses = test[id, :]
    average = mean(getvalue, responses)
    return average
end

function personmean(test::PsychometricTest, id, scale::Symbol)
    responses = getresponses(test, scale)[P = At(id)]
    average = mean(getvalue, responses)
    return average
end

"""
    itemmeans(test::PsychometricTest)

Calculate the mean scores for each item in `test`.
"""
function itemmeans(test::PsychometricTest)
    responses = getresponses(test)
    average = mean(getvalue, responses, dims = P)
    return average
end

function itemmeans(test::PsychometricTest, scale::Symbol)
    responses = getresponses(test, scale)
    average = mean(getvalue, responses, dims = P)
    return average
end

"""
    itemmean(test::PsychometricTest, id)

Calculate the mean score for item with identifier `id` in `test`.
"""
function itemmean(test::PsychometricTest, id)
    responses = test[:, id]
    average = mean(getvalue, responses)
    return average
end

function itemcov(test::PsychometricTest; corrected::Bool = true)
    C = cov(response_matrix(test), dims = P; corrected)
    return C
end

function itemcor(test::PsychometricTest; corrected::Bool = true)
    C = itemcov(test; corrected)
    return cov2cor!(C, sqrt.(diag(C)))
end

function personcov(test::PsychometricTest; corrected::Bool = true)
    C = cov(response_matrix(test), dims = I; corrected)
    return C
end

function personcor(test::PsychometricTest; corrected::Bool = true)
    C = personcov(test; corrected)
    return cov2cor!(C, sqrt.(diag(C)))
end
