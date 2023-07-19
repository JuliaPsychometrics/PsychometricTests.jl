using PrecompileTools

@compile_workload begin
    m = rand(0:1, 10, 4)
    test = PsychometricTest(m)

    item_data = rand(0:1, 10)
    tbl = (a = item_data, b = item_data, c = item_data)
    test = PsychometricTest(tbl)

    # descriptive statistics
    personscores(test)
    personscore(test, 1)
    itemscores(test)
    itemscore(test, 1)
    personmeans(test)
    personmean(test, 1)
    itemmeans(test)
    itemmean(test, 1)
    itemcov(test)
    itemcor(test)
    personcov(test)
    personcor(test)

    # test splitting
    split(test, :, [:a, :b])
    split(test, 1:5, :)
end
