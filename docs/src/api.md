```@meta
CurrentModule = PsychometricTests
```

# API

## Types / Constructors
```@docs
PsychometricTest
PsychometricTest(::AbstractVector{<:Item}, ::AbstractVector{<:Person}, ::AbstractVector{<:Response})
PsychometricTest(::AbstractMatrix)
PsychometricTest(::Any)
Item
Person
Response
BasicItem
BasicPerson
BasicResponse
Matrix
```

## Accessors
```@docs
getitems
getpersons
getresponses
getvalue
getid
getitemid
getpersonid
nitems
npersons
nresponses
```

## Iterators
```@docs
eachitem
eachperson
eachresponse
```

## Descriptive Statistics
```@docs
itemmean
itemmeans
itemscore
itemscores
personmean
personmeans
personscore
personscores
```
