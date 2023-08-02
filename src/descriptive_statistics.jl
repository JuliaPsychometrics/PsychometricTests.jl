"""
    personscores(test::PsychometricTest)
    personscores(test::PsychometricTest, scale::Symbol)

Calculate the total scores for each person in `test`.
"""
function personscores(test::PsychometricTest, args...)
    responses = response_matrix(test, args...)
    scores = sum(responses, dims = I)
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
    itemscores(test::PsychometricTest, scale::Symbol)

Calculate the total score for each item in `test`.
"""
function itemscores(test::PsychometricTest, args...)
    responses = response_matrix(test, args...)
    scores = sum(responses, dims = P)
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
function personmeans(test::PsychometricTest, args...)
    responses = response_matrix(test, args...)
    average = mean(responses, dims = I)
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
    itemmeans(test::PsychometricTest, scale::Symbol)

Calculate the mean scores for each item in `test`.
"""
function itemmeans(test::PsychometricTest, args...)
    responses = response_matrix(test, args...)
    average = mean(responses, dims = P)
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


"""
    itemcov(test::PsychometricTest; corrected = false)
    itemcov(test::PsychometricTest, scale::Symbol; corrected = false)

Calculate the item covariance matrix.
"""
function itemcov(test::PsychometricTest, args...; corrected::Bool = true)
    responses = response_matrix(test, args...)
    C = cov(responses, dims = P; corrected)
    return C
end

"""
    itemcor(test::PsychometricTest; corrected = false)
    itemcor(test::PsychometricTest, scale::Symbol; corrected = false)

Calculate the item correlation matrix.
"""
function itemcor(test::PsychometricTest, args...; kwargs...)
    C = itemcov(test, args...; kwargs...)
    return cov2cor!(C, sqrt.(diag(C)))
end

"""
    personcov(test::PsychometricTest; corrected = false)
    personcov(test::PsychometricTest, scale::Symbol; corrected = false)

Calculate the person covariance matrix.
"""
function personcov(test::PsychometricTest, args...; corrected::Bool = true)
    responses = response_matrix(test, args...)
    C = cov(responses, dims = I; corrected)
    return C
end

"""
    personcor(test::PsychometricTest; corrected = false)
    personcor(test::PsychometricTest, scale::Symbol; corrected = false)

Calculate the person correlation matrix.
"""
function personcor(test::PsychometricTest, args...; kwargs...)
    C = personcov(test, args...; kwargs...)
    return cov2cor!(C, sqrt.(diag(C)))
end
