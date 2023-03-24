using PsychometricTests
using Documenter

DocMeta.setdocmeta!(
    PsychometricTests,
    :DocTestSetup,
    :(using PsychometricTests);
    recursive = true,
)

makedocs(;
    modules = [PsychometricTests],
    authors = "Philipp Gewessler",
    repo = "https://github.com/JuliaPsychometrics/PsychometricTests.jl/blob/{commit}{path}#{line}",
    sitename = "PsychometricTests.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://JuliaPsychometrics.github.io/PsychometricTests.jl",
        edit_link = "main",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "Extending Types" => "extending_types.md",
        "API" => "api.md",
    ],
)

deploydocs(;
    repo = "github.com/JuliaPsychometrics/PsychometricTests.jl",
    devbranch = "main",
)
