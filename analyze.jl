using CSV, DataFrames, Statistics, Plots, LaTeXStrings; pyplot()

function statsSummary(;doPlot = true)
    cd(@__DIR__)
    results = DataFrame(CSV.File("results.csv"))

    γVals = [0.2,0.4,0.6,0.8]
    nVals = collect(3:8)
    cFracVals = collect(0.05:0.05:0.950)
    plotDict = Dict()

    for γ in γVals
        for n in nVals
            tempResults =  filter([:γ, :n] => (γdf, ndf) -> γdf == γ  && ndf == n, results)
            tempResultsCG = filter(:gappingPolicy => gp -> gp,tempResults)
            tempResultsCO = filter(:gappingPolicy => gp -> !gp,tempResults)
            diffs = zeros(length(cFracVals))
            for (i,cf) in enumerate(cFracVals)
                rwdsCG = filter(:cFrac => cfv -> cfv == cf,tempResultsCG).reward
                avgCG = mean(rwdsCG)
                rwdsCO = filter(:cFrac => cfv -> cfv == cf,tempResultsCO).reward
                avgCO = mean(rwdsCO)
                diffs[i] = avgCO - avgCG
            end
            push!(plotDict,(γ,n) => diffs)
            md, i = findmax(diffs)
            cMax = cFracVals[i]
            diffsAtMax = tempResultsCO[tempResultsCO.cFrac .== cMax,:reward] - tempResultsCG[tempResultsCG.cFrac .== cMax,:reward]
            reps = length(diffsAtMax)
            @show reps
            serr = std(diffsAtMax)/sqrt(reps)
            @show n, γ,  md, md-1.96serr,md+1.96serr, cMax*γ^2 
        end
    end
    plotDict
end



plotDict = statsSummary(doPlot=true)
plts = []
for γ in [0.2,0.4,0.6,0.8]
    cVals = (0.05:0.05:0.950)*γ^2
    @show cVals
    plot(cVals,plotDict[(γ,3)],label="n=3")
    plot!(cVals,plotDict[(γ,4)],label="n=4")
    plot!(cVals,plotDict[(γ,5)],label="n=5")
    plot!(cVals,plotDict[(γ,6)],label="n=6")
    plot!(cVals,plotDict[(γ,7)],label="n=7")
    p = plot!(cVals,plotDict[(γ,8)],label="n=8",title = L"\gamma = "*string(γ),xlabel="c",ylabel="Policy Diff")
    push!(plts,p)
end

plot(plts...)

