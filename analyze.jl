using CSV, DataFrames, Statistics, Plots, LaTeXStrings; pyplot()

function statsSummary(;doPlot = true)
    cd(@__DIR__)
    results = DataFrame(CSV.File("results.csv"))

    γVals = [0.2,0.4,0.6,0.8]
    nVals = collect(3:8)
    cFracVals = collect(0.05:0.05:0.950)
    plotDict = Dict()
    resultsDict = Dict()

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
            serr = std(diffsAtMax)/sqrt(reps)
            # @show n, γ,  md, md-1.96serr,md+1.96serr, cMax*γ^2 
            push!(resultsDict,(γ,n) => (round(md,digits=4),round(1.96serr,digits =4),round(cMax*γ^2,digits=4)))
        end
    end
    plotDict,resultsDict
end

function doPlot()
    plts = []
    doLegend = true
    for γ in [0.2,0.4,0.6,0.8]
        cVals = (0.05:0.05:0.950)*γ^2
        plot(cVals,plotDict[(γ,3)],label="n=3")
        plot!(cVals,plotDict[(γ,4)],label="n=4")
        plot!(cVals,plotDict[(γ,5)],label="n=5")
        plot!(cVals,plotDict[(γ,6)],label="n=6")
        plot!(cVals,plotDict[(γ,7)],label="n=7")
        p = plot!(cVals,plotDict[(γ,8)],label="n=8",title = L"\gamma = "*string(γ),xlabel="c",ylabel="Policy Diff",legend=doLegend)
        doLegend = false
        push!(plts,p)
    end
    plot(plts...)
end


function formatTable(rd)
    gg(g,n) = rd[(g,n)][1]
    ee(g,n) = rd[(g,n)][2]
    cc(g,n) = rd[(g,n)][3]

    tableString = """
    \\begin{table}[h!]
    \\begin{center}
      \\caption{Evaluating the difference between the call-gapping and the cool-off policy.}
      \\label{tab:table1}
      \\begin{tabular}{|c|c|c|l|} 
        \\hline
        \\textbf{System} & \\textbf{Number of channels} & \\textbf{Maximal Gap}& \\textbf{Worst cost} \\\\
        \\hline
        \\multirow{6}{*}{ \$\\gamma = 0.2 \$} 
        &  \$n=3 \$ &  \$$(gg(0.2,3)) \\pm $(ee(0.2,3)) \$ &  \$c = $(cc(0.2,3)) \$\\\\ 
        &  \$n=4 \$ &  \$$(gg(0.2,4)) \\pm $(ee(0.2,4)) \$ &  \$c = $(cc(0.2,4)) \$ \\\\
        &  \$n=5 \$ &  \$$(gg(0.2,5)) \\pm $(ee(0.2,5)) \$ &  \$c = $(cc(0.2,5)) \$ \\\\
        &  \$n=6 \$ &  \$$(gg(0.2,6)) \\pm $(ee(0.2,6)) \$ &  \$c = $(cc(0.2,6)) \$ \\\\
        &  \$n=7 \$ &  \$$(gg(0.2,7)) \\pm $(ee(0.2,7)) \$ &  \$c = $(cc(0.2,7)) \$ \\\\
        &  \$n=8 \$ &  \${\\bf $(gg(0.2,8))} \\pm $(ee(0.2,8)) \$ &  \$c = $(cc(0.2,8)) \$ \\\\
        \\hline
        \\multirow{6}{*}{ \$\\gamma = 0.4 \$} 
        &  \$n=3 \$ &  \$$(gg(0.4,3)) \\pm $(ee(0.4,3)) \$ &  \$c = $(cc(0.4,3)) \$\\\\ 
        &  \$n=4 \$ &  \$$(gg(0.4,4)) \\pm $(ee(0.4,4)) \$ &  \$c = $(cc(0.4,4)) \$ \\\\
        &  \$n=5 \$ &  \${\\bf $(gg(0.4,5))} \\pm $(ee(0.4,5)) \$ &  \$c = $(cc(0.4,5)) \$ \\\\
        &  \$n=6 \$ &  \$$(gg(0.4,6)) \\pm $(ee(0.4,6)) \$ &  \$c = $(cc(0.4,6)) \$ \\\\
        &  \$n=7 \$ &  \$$(gg(0.4,7)) \\pm $(ee(0.4,7)) \$ &  \$c = $(cc(0.4,7)) \$ \\\\
        &  \$n=8 \$ &  \$$(gg(0.4,8)) \\pm $(ee(0.4,8)) \$ &  \$c = $(cc(0.4,8)) \$ \\\\
        \\hline
        \\multirow{6}{*}{ \$\\gamma = 0.6 \$} 
        &  \$n=3 \$ &  \$$(gg(0.6,3)) \\pm $(ee(0.6,3)) \$ &  \$c = $(cc(0.6,3)) \$\\\\ 
        &  \$n=4 \$ &  \${ \\bf $(gg(0.6,4))} \\pm $(ee(0.6,4)) \$ &  \$c = $(cc(0.6,4)) \$ \\\\
        &  \$n=5 \$ &  \$$(gg(0.6,5)) \\pm $(ee(0.6,5)) \$ &  \$c = $(cc(0.6,5)) \$ \\\\
        &  \$n=6 \$ &  \$$(gg(0.6,6)) \\pm $(ee(0.6,6)) \$ &  \$c = $(cc(0.6,6)) \$ \\\\
        &  \$n=7 \$ &  \$$(gg(0.6,7)) \\pm $(ee(0.6,7)) \$ &  \$c = $(cc(0.6,7)) \$ \\\\
        &  \$n=8 \$ &  \$$(gg(0.6,8)) \\pm $(ee(0.6,8)) \$ &  \$c = $(cc(0.6,8)) \$ \\\\
        \\hline
        \\multirow{6}{*}{ \$\\gamma = 0.8 \$} 
        &  \$n=3 \$ &  \$$(gg(0.8,3)) \\pm $(ee(0.8,3)) \$ &  \$c = $(cc(0.8,3)) \$\\\\ 
        &  \$n=4 \$ &  \$$(gg(0.8,4)) \\pm $(ee(0.8,4)) \$ &  \$c = $(cc(0.8,4)) \$ \\\\
        &  \$n=5 \$ &  \$ {\\bf $(gg(0.8,5))} \\pm $(ee(0.8,5)) \$ &  \$c = $(cc(0.8,5)) \$ \\\\
        &  \$n=6 \$ &  \$$(gg(0.8,6)) \\pm $(ee(0.8,6)) \$ &  \$c = $(cc(0.8,6)) \$ \\\\
        &  \$n=7 \$ &  \$$(gg(0.8,7)) \\pm $(ee(0.8,7)) \$ &  \$c = $(cc(0.8,7)) \$ \\\\
        &  \$n=8 \$ &  \$$(gg(0.8,8)) \\pm $(ee(0.8,8)) \$ &  \$c = $(cc(0.8,8)) \$ \\\\
        \\hline
      \\end{tabular}
    \\end{center}
  \\end{table}"""
  println(tableString)
  nothing
end



plotDict, resultsDict = statsSummary(doPlot=true)

formatTable(resultsDict)

doPlot()