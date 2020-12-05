using Distributions, Random

#Simulates with the call gapping policy
function simCallGapping(N,τ,γ,c,tMax, seed = 1974)
    Random.seed!(seed)
    state = [0 for _ in 1:N]
    currentArm = 1
    allowedToSwitch = false
    t = 0.0
    reward = 0.0 
    λ, μ = 1.0, 1/γ - 1
    rλ() = rand(Exponential(1/λ))
    rμ() = rand(Exponential(1/μ))
    nextArm(i) = (i%N)+1

    #N+1 event types in this discrete event simulation
    timeJumps = [rλ() for _ in 1:N] 
    push!(timeJumps,τ) #The last one is for the call gapping
        
    while t<tMax
       tLast = t 
       t,i = findmin(timeJumps)
       reward += state[currentArm]*(t-tLast)
        
       if i == N+1 #call gapping timer up
            #println("$(t),$(currentArm): gap reached")
            if state[currentArm] == 0
                #println("$(t),$(currentArm): switching from $(currentArm)")
                currentArm = nextArm(currentArm)
                allowedToSwitch = false
                timeJumps[N+1] = t+τ
                reward -= c
            else
                allowedToSwitch = true
                timeJumps[N+1] = Inf
            end
        else #arm changing state
           if state[i] == 0
              #println("$(t),$(currentArm): Arm $(i) switch to 1")  
              state[i] = 1
              timeJumps[i] = t+rμ()
           else #state was 1
               #println("$(t),$(currentArm): Arm $(i) switch to 0")  
               state[i] = 0
               timeJumps[i] = t+rλ()
               if allowedToSwitch && state[currentArm] == 0
                    #println("$(t),$(currentArm): switching from $(currentArm)")
                    currentArm = nextArm(currentArm)
                    allowedToSwitch = false
                    timeJumps[N+1] = t+τ
                    reward -= c
               end
           end
       end
    end
    reward/tMax
end