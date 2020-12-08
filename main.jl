using DataFrames, CSV, Dates
cd(@__DIR__)

function simulate()

    results = DataFrame(γ = Float32[], n = Int[], cFrac = Float32[], 
                        gappingPolicy = Bool[], τσParam = Float32[],reward=Float32[],seed=Int[])

    γVals = [0.2,0.4,0.6,0.8]
    nVals = collect(3:8)
    cFracVals = collect(0.05:0.05:0.95)
    for repetition in 1:30 
        @show repetition
        println(Dates.format(now(), "HH:MM"))
        for γ in γVals
            for n in nVals
                for cFrac in cFracVals
                    @show (γ,n,cFrac)
                    optCG = optimize(simCallGapping,n,γ,cFrac,seed=repetition)
                    push!(results,[γ,n,cFrac,true,optCG[1],optCG[2],repetition]) #Call gapping is true
                    optCO = optimize(simCoolOff,n,γ,cFrac)
                    push!(results,[γ,n,cFrac,false,optCO[1],optCO[2],repetition]) #Cool off is false
                end
                @info "Writing results to file"
                CSV.write("results.csv",results)    
            end
        end
    end
end

simulate()