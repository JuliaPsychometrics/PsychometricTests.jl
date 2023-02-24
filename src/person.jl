abstract type Person end

getid(person::Person) = person.id

struct BasicPerson{I} <: Person
    id::I
end
