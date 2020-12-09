using CSV, DataFrames, Statistics, Plots, LaTeXStrings; pyplot()

include("simParams.jl")

function statsSummary(;doPlot = true)
    cd(@__DIR__)
    results = DataFrame(CSV.File("results.csv"))

    plotDict = Dict()
    resultsDict = Dict()

    for (j,γ) in enumerate(γVals)
        for n in nVals[j]
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
            push!(resultsDict,(γ,n) => (round(md,digits=5),round(1.96serr,digits =5),round(cMax*γ^2,digits=5)))
        end
    end
    plotDict,resultsDict
end

function doPlot()
    plts = []
    doLegend = true
    for (j,γ) in enumerate(γVals)
        cVals = cFracVals*γ^2
        nnVals = nVals[j]
        p = plot(cVals,plotDict[(γ,nnVals[1])],label="n=$(nnVals[1])")
        for i in 2:length(nnVals)
            p = plot!(cVals,plotDict[(γ,nnVals[i])],
                label="n=15",title = L"\gamma = "*string(γ),
                xlabel="c",ylabel="Policy Diff",legend=doLegend)
        end
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
      \\caption{Evaluating the difference between the cool-off and call-gapping policy.}
      \\label{tab:table1}
      \\begin{tabular}{|c|c|l|l|} 
        \\hline
        \\textbf{System} & \\textbf{Number of channels} & \\textbf{Maximal Gap}& \\textbf{Worst cost} \\\\
        \\hline
        \\multirow{18}{*}{ \$\\gamma = 0.2 \$} 
        &  \$n=3 \$ &  \$$(gg(0.2,3)) \\pm $(ee(0.2,3)) \$ &  \$c = $(cc(0.2,3)) \$\\\\ 
        &  \$n=4 \$ &  \$$(gg(0.2,4)) \\pm $(ee(0.2,4)) \$ &  \$c = $(cc(0.2,4)) \$ \\\\
        &  \$n=5 \$ &  \$$(gg(0.2,5)) \\pm $(ee(0.2,5)) \$ &  \$c = $(cc(0.2,5)) \$ \\\\
        &  \$n=6 \$ &  \$$(gg(0.2,6)) \\pm $(ee(0.2,6)) \$ &  \$c = $(cc(0.2,6)) \$ \\\\
        &  \$n=7 \$ &  \$$(gg(0.2,7)) \\pm $(ee(0.2,7)) \$ &  \$c = $(cc(0.2,7)) \$ \\\\
        &  \$n=8 \$ &  \${ $(gg(0.2,8))} \\pm $(ee(0.2,8)) \$ &  \$c = $(cc(0.2,8)) \$ \\\\
        &  \$n=9 \$ &  \${  $(gg(0.2,9))} \\pm $(ee(0.2,9)) \$ &  \$c = $(cc(0.2,9)) \$ \\\\
        &  \$n=10 \$ &  \${ $(gg(0.2,10))} \\pm $(ee(0.2,10)) \$ &  \$c = $(cc(0.2,10)) \$ \\\\
        &  \$n=11 \$ &  \${ $(gg(0.2,11))} \\pm $(ee(0.2,11)) \$ &  \$c = $(cc(0.2,11)) \$ \\\\
        &  \$n=12 \$ &  \${ $(gg(0.2,12))} \\pm $(ee(0.2,12)) \$ &  \$c = $(cc(0.2,12)) \$ \\\\
        &  \$n=13 \$ &  \${ $(gg(0.2,13))} \\pm $(ee(0.2,13)) \$ &  \$c = $(cc(0.2,13)) \$ \\\\
        &   \${\\bf n=14} \$ &  \${\\bf $(gg(0.2,14)) \\pm $(ee(0.2,14))} \$ &  \$c = $(cc(0.2,14)) \$ \\\\
        &  \$ {\\bf n=15} \$ &  \${\\bf $(gg(0.2,15)) \\pm $(ee(0.2,15))} \$ &  \$c = $(cc(0.2,15)) \$ \\\\
        &  \$ {\\bf n=16} \$ &  \${\\bf $(gg(0.2,16)) \\pm $(ee(0.2,16))} \$ &  \$c = $(cc(0.2,16)) \$ \\\\
        &  \$n=17 \$ &  \${ $(gg(0.2,17))} \\pm $(ee(0.2,17)) \$ &  \$c = $(cc(0.2,17)) \$ \\\\
        &  \$n=18 \$ &  \${ $(gg(0.2,18))} \\pm $(ee(0.2,18)) \$ &  \$c = $(cc(0.2,18)) \$ \\\\
        &  \$n=19 \$ &  \${ $(gg(0.2,19))} \\pm $(ee(0.2,19)) \$ &  \$c = $(cc(0.2,19)) \$ \\\\
        &  \$n=20 \$ &  \${ $(gg(0.2,20))} \\pm $(ee(0.2,20)) \$ &  \$c = $(cc(0.2,20)) \$ \\\\
        \\hline
        \\multirow{13}{*}{ \$\\gamma = 0.3\$} 
        &  \$n=3 \$ &  \$$(gg(0.3,3)) \\pm $(ee(0.3,3)) \$ &  \$c = $(cc(0.3,3)) \$\\\\ 
        &  \$n=4 \$ &  \$$(gg(0.3,4)) \\pm $(ee(0.3,4)) \$ &  \$c = $(cc(0.3,4)) \$ \\\\
        &  \$n=5 \$ &  \${ $(gg(0.3,5))} \\pm $(ee(0.3,5)) \$ &  \$c = $(cc(0.3,5)) \$ \\\\
        &  \$n=6 \$ &  \$$(gg(0.3,6)) \\pm $(ee(0.3,6)) \$ &  \$c = $(cc(0.3,6)) \$ \\\\
        &  \$n=7 \$ &  \$$(gg(0.3,7)) \\pm $(ee(0.3,7)) \$ &  \$c = $(cc(0.3,7)) \$ \\\\
        &  \$n=8 \$ &  \${ $(gg(0.3,8))} \\pm $(ee(0.3,8)) \$ &  \$c = $(cc(0.3,8)) \$ \\\\
        &  \${\\bf n=9} \$ &  \${\\bf $(gg(0.3,9)) \\pm $(ee(0.3,9))} \$ &  \$c = $(cc(0.3,9)) \$ \\\\
        &  \$n=10 \$ &  \$$(gg(0.3,10)) \\pm $(ee(0.3,10)) \$ &  \$c = $(cc(0.3,10)) \$ \\\\
        &  \$n=11 \$ &  \$$(gg(0.3,11)) \\pm $(ee(0.3,11)) \$ &  \$c = $(cc(0.3,11)) \$ \\\\
        &  \$n=12 \$ &  \$$(gg(0.3,12)) \\pm $(ee(0.3,12)) \$ &  \$c = $(cc(0.3,12)) \$ \\\\
        &  \$n=13 \$ &  \$$(gg(0.3,13)) \\pm $(ee(0.3,13)) \$ &  \$c = $(cc(0.3,13)) \$ \\\\
        &  \$n=14 \$ &  \$$(gg(0.3,14)) \\pm $(ee(0.3,14)) \$ &  \$c = $(cc(0.3,14)) \$ \\\\
        &  \$n=15 \$ &  \$$(gg(0.3,15)) \\pm $(ee(0.3,15)) \$ &  \$c = $(cc(0.3,15)) \$ \\\\
        \\hline
        \\multirow{8}{*}{ \$\\gamma = 0.4\$} 
        &  \$n=3 \$ &  \$$(gg(0.4,3)) \\pm $(ee(0.4,3)) \$ &  \$c = $(cc(0.4,3)) \$\\\\ 
        &  \$n=4 \$ &  \$$(gg(0.4,4)) \\pm $(ee(0.4,4)) \$ &  \$c = $(cc(0.4,4)) \$ \\\\
        &  \$n=5 \$ &  \${ $(gg(0.4,5))} \\pm $(ee(0.4,5)) \$ &  \$c = $(cc(0.4,5)) \$ \\\\
        &  \$n=6 \$ &  \${ $(gg(0.4,6))} \\pm $(ee(0.4,6)) \$ &  \$c = $(cc(0.4,6)) \$ \\\\
        &  \${\\bf n=7} \$ &  \${\\bf $(gg(0.4,7)) \\pm $(ee(0.4,7))} \$ &  \$c = $(cc(0.4,7)) \$ \\\\
        &  \$n=8 \$ &  \$$(gg(0.4,8)) \\pm $(ee(0.4,8)) \$ &  \$c = $(cc(0.4,8)) \$ \\\\
        &  \$n=9 \$ &  \$$(gg(0.4,9)) \\pm $(ee(0.4,9)) \$ &  \$c = $(cc(0.4,9)) \$ \\\\
        &  \$n=10 \$ &  \$$(gg(0.4,10)) \\pm $(ee(0.4,10)) \$ &  \$c = $(cc(0.4,10)) \$ \\\\

        \\hline
        \\multirow{3}{*}{ \$\\gamma = 0.6 \$} 
        &  \$n=3 \$ &  \$$(gg(0.6,3)) \\pm $(ee(0.6,3)) \$ &  \$c = $(cc(0.6,3)) \$\\\\ 
        &  \${\\bf n=4} \$ &  \${ \\bf $(gg(0.6,4)) \\pm $(ee(0.6,4))} \$ &  \$c = $(cc(0.6,4)) \$ \\\\
        &  \$n=5 \$ &  \$$(gg(0.6,5)) \\pm $(ee(0.6,5)) \$ &  \$c = $(cc(0.6,5)) \$ \\\\
        \\hline
        \\multirow{3}{*}{ \$\\gamma = 0.8 \$} 
        &  \${\\bf n=3 }\$ &  \${\\bf $(gg(0.8,3)) \\pm $(ee(0.8,3))} \$ &  \$c = $(cc(0.8,3)) \$\\\\ 
        &  \$n=4 \$ &  \$$(gg(0.8,4)) \\pm $(ee(0.8,4)) \$ &  \$c = $(cc(0.8,4)) \$ \\\\
        &  \$n=5 \$ &  \$ { $(gg(0.8,5))} \\pm $(ee(0.8,5)) \$ &  \$c = $(cc(0.8,5)) \$ \\\\
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