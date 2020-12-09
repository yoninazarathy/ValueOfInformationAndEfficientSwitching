using DataFrames, CSV, Dates

include("callGapping.jl")
include("coolOff.jl")
include("optimize.jl")
include("simParams.jl")
cd(@__DIR__)

function simulate()

    results = DataFrame(γ = Float32[], n = Int[], cFrac = Float32[], 
                        gappingPolicy = Bool[], τσParam = Float32[],reward=Float32[],seed=Int[])

    lastCGparam = -1
    lastCOparam = -1
    for repetition in 1:100 
        @show repetition
        println(Dates.format(now(), "HH:MM"))
        for (j,γ) in enumerate(γVals)
            for cFrac in cFracVals
                opt2 = opt2τσ(γ,cFrac)
                for (i,n) in enumerate(nVals[j])
                    @show (γ,n,cFrac)
                    upperLimit = (i == 1 ? opt2 :  lastCGparam)*1.1
                    optCG = optimize(simCallGapping,n,γ,cFrac,upperLimit,seed=repetition)
                    lastCGparam = optCG[1]
                    push!(results,[γ,n,cFrac,true,optCG[1],optCG[2],repetition]) #Call gapping is true
                    
                    upperLimit = (i == 1 ? opt2 :  lastCOparam)*1.1
                    optCO = optimize(simCoolOff,n,γ,cFrac,upperLimit,seed=repetition)
                    lastCOparam = optCO[1]
                    push!(results,[γ,n,cFrac,false,optCO[1],optCO[2],repetition]) #Cool off is false
                end
            end
            @info "Writing results to file"
            CSV.write("results.csv",results)    
        end
    end
end

simulate()