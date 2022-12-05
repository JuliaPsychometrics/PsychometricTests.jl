using PsychometricTests
using Documenter

DocMeta.setdocmeta!(PsychometricTests, :DocTestSetup, :(using PsychometricTests); recursive=true)

makedocs(;
    modules=[PsychometricTests],
    authors="Philipp Gewessler",
    repo="https://github.com/p-gw/PsychometricTests.jl/blob/{commit}{path}#{line}",
    sitename="PsychometricTests.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://p-gw.github.io/PsychometricTests.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/p-gw/PsychometricTests.jl",
    devbranch="main",
)
