using PrecompileTools

@compile_workload begin
    m = rand(0:1, 10, 4)
    test = PsychometricTest(m)

    item_data = rand(0:1, 10)
    tbl = (a = item_data, b = item_data, c = item_data)
    test = PsychometricTest(tbl)

    # descriptives
    personscores(test)
    itemscores(test)
    personmeans(test)
    itemmeans(test)

    # test splitting
    split(test, :, [:a, :b])
    split(test, 1:5, :)
end
