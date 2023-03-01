# PsychometricTests.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://p-gw.github.io/PsychometricTests.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://p-gw.github.io/PsychometricTests.jl/dev/)
[![Build Status](https://github.com/p-gw/PsychometricTests.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/p-gw/PsychometricTests.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/p-gw/PsychometricTests.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/p-gw/PsychometricTests.jl)

PsychometricTests.jl provides data structures for psychometric testing in Julia.
It serves as an entry point to the [JuliaPsychometrics](https://github.com/JuliaPsychometrics)
ecosystem of packages.

## Installation
To install this package simply use Julias package management system

```julia
] add PsychometricTests
```

## Getting started
PsychometricTests.jl allows construction and basic analysis of psychometric tests with
`PsychometricTest`. Tests can be constructed from scratch, from an person by item response
matrix, or from a [Tables.jl](https://github.com/JuliaData/Tables.jl) compatible source such 
as [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl).

```julia
using PsychometricTests
 
response_data = rand(0:1, 10, 3)
test = PsychometricTest(response_data)
```

After successful construction, `test` can be used to query responses,

```julia
test[1, :]  # get all responses for person 1
test[:, 2]  # get all responses for item 2
```

and do simple descriptive analysis, such as calculating the total scores for all persons,

```julia
personscores(test)
```

## Extending PsychometricTest
PsychometricTests.jl includes a minimal implementation for item, person, and response types.
However, in practice more complex types might be required. 
We provide means to extend the existing types to facilitate these types of analyses. 
Please see the docs for more details.
