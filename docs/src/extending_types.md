```@meta
CurrentModule = PsychometricTests
```

# Extending Types
While PsychometricTests.jl implements minimal versions for test components with 
[`BasicItem`](@ref), [`BasicPerson`](@ref), and [`BasicResponse`](@ref), more compex use
cases might require extensions of these basic components. 
In this example we will create a psychometric test that not only includes variables on the
person level, but also response times for the item responses.
The resulting [`PsychometricTest`](@ref) stores the required information and has the
capability to analyse response times.

## Adding Person variables
In a first step we add additional variables to the `persons` field of the psychometric test. 
For this we need to create a new `struct` that inherits from [`Person`](@ref).
This struct contains the persons anger score in an `anger` field. 
Additionally the interface definition of [`Person`](@ref) requires us to add a unique identifier
for each person. We include this in an `id` field of the struct.

```@example extending-types
using PsychometricTests

struct AngryPerson{T} <: Person
    id::T
    anger::Int
end
```

The [`Person`](@ref) interface requires a [`getid`](@ref) method for all implementations.
The default method accesses the `id` field of the struct. 
Since the unique person identifier is stored in the `id` field of `AngryPerson`, no further implementations are required.

## Adding response times
The second step in this example is to add response times to [`BasicResponse`](@ref). Similarly to
adding the person variables we create a `struct` inheriting from [`Response`](@ref) and 
implement the required interface. The new `TimedResponse` has additional `start_time` and 
`end_time` variables that can be used to calculate the response times. 

```@example extending-types
using Dates

struct TimedResponse{IIT,PIT,T} <: Response
    item_id::IIT
    person_id::PIT
    value::T
    start_time::DateTime
    end_time::DateTime
end
```

The interface for [`Response`](@ref) requires implemtation of [`getvalue`](@ref), 
[`getitemid`](@ref), and [`getpersonid`](@ref). 
The default methods access the `value`, `item_id` and `person_id` of the struct respectively.
Just as before, no further interface implementations are necessary in this case.

Additionally we want to be able to get the response time for a given response, so we define
a custom `response_time` function. 

```@example extending-types
response_time(response::TimedResponse) = response.end_time - response.start_time
```

This concludes the type definition section of this example.
Next, we will move on to constructing the psychometric test.

## Constructing the test
To construct a psychometric test from our custom structs we need some items, persons, and 
responses. In this example we will simply use randomly generated data. 

For items we just need some [`BasicItem`](@ref),

```@example extending-types
items = [BasicItem(i) for i in 1:2]
```

Persons have some `anger` score (0 - 20) in addition to a unique id, 

```@example extending-types
persons = [AngryPerson(p, rand(0:20)) for p in 1:3]
```

Similarly, the `TimedResponse` for the test will have some randomly generated 
timings, 

```@example extending-types
responses = TimedResponse{Int,Int,Int}[]

for i in 1:2, p in 1:3
    start_time = now()
    end_time = start_time + Second(rand(10:600))
    response = TimedResponse(i, p, rand(0:1), start_time, end_time)
    push!(responses, response)
end

responses
```

The last step is to finally construct the psychometric test.

```@example extending-types
timed_test = PsychometricTest(items, persons, responses)
```

The `timed_test` is subject to our usual analyses, such as calculating scores.

```@example extending-types
personscores(timed_test)
```

Additionally we can efficiently query the custom fields, e.g.

```@example extending-types
response_times = [response_time(r) for r in eachresponse(timed_test)]
```
