function optimize(simFunction,N,γ,cFrac; seed = 1974, tMax = 10^4,δ = 0.01) 
    τσMax = opt2τσ(γ,cFrac)*1.1
    τσGrid = δ:δ:τσMax
    cMax = γ^2

    c = cFrac*cMax
    vals = [simFunction(N,τσ,γ,c,tMax, seed = seed) for τσ in τσGrid]
    g, i = findmax(vals)
    τStar = τσGrid[i]
    return τStar, g
end


