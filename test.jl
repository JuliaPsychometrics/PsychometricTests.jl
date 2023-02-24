using BenchmarkTools
using PsychometricTests

using UUIDs

I = 10
P = 100

items = [BasicItem(uuid4()) for i in 1:I]
persons = [BasicPerson(uuid4()) for p in 1:P]

# matrix to long format
N = I * P

responses_long = Vector{BasicResponse}(undef, N)
item_id = Vector{Int}(undef, N)
person_id = Vector{Int}(undef, N)

n = 0
for i in 1:I
    for p in 1:P
        n += 1
        item_id[n] = i
        person_id[n] = p
        responses_long[n] = responses[p, i]
    end
end

item_ptr = [findall(x -> x .== i, item_id) for i in 1:I]
person_ptr = [findall(x -> x .== p, person_id) for p in 1:P]

test = PsychometricTest(items, persons, responses_long, item_ptr, person_ptr, 0)
