include("twoChannels.jl")

function optimize(simFunction,N,γ,cFrac,upperLimit; seed = 1974, tMax = 10^3,M = 20) 
    δ = upperLimit/M
    τσGrid = δ:δ:upperLimit
    c = cFrac*γ^2
    vals = [simFunction(N,τσ,γ,c,tMax, seed = seed) for τσ in τσGrid]
    g, i = findmax(vals)
    τStar = τσGrid[i]
    return τStar, g
end


