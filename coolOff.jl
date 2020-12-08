using Distributions, Random

#Simulates with the cool off policy
function simCoolOff(N,σ,γ,c,tMax; seed = 1974)
    Random.seed!(seed)
    state = [0 for _ in 1:N] #actual state of arms
    allowedToSwitchTo = [true for _ in 1:N] #state of belief state of arms (true => passed the threshold)
    currentArm = 1
    t = 0.0
    reward = 0.0
    λ, μ = 1.0, 1/γ - 1
    rλ() = rand(Exponential(1/λ))
    rμ() = rand(Exponential(1/μ))
    nextArm(i) = (i%N)+1
    
    #2N event types in this discrete event simulation
    timeJumps = [rλ() for _ in 1:N] #first N events are for state change
    append!(timeJumps,fill(σ,N)) #initilize N events for "ok to switch to arm"
    timeJumps[currentArm + N] = Inf
        
    #assumes the currentArm is bad (in 0) and searches for a better arm afterwards
    function searchForNextArm()
        na = nextArm(currentArm)
        for _ in 1:N-1 #loop untill either (1) found a good arm (2) no where to switch to
            if allowedToSwitchTo[na] #if allowed to switch - lets do it
                timeJumps[currentArm + N] = t + σ #leaving arm so set the belief update
                allowedToSwitchTo[currentArm] = false
                currentArm = na
                reward -= c
               # @show timeJumps
                if state[currentArm] == 1 #we are happy and leave
                    break
                end
            end
            na = nextArm(na)
        end
        timeJumps[currentArm + N] = Inf
    end
    
    while t<tMax
       tLast = t 
       t,i = findmin(timeJumps)
       reward += state[currentArm]*(t-tLast)
        if i >= N+1 #pass the omega threshold event
            allowedToSwitchTo[i-N] = true 
            if state[currentArm] == 0
                searchForNextArm()
            else
                timeJumps[i] = Inf
            end
        else #arm i is changing state event
           if state[i] == 0
              state[i] = 1
              timeJumps[i] = t + rμ()
           else #state was 1
                state[i] = 0
                timeJumps[i] = t + rλ()
                if allowedToSwitchTo[nextArm(currentArm)] && state[currentArm] == 0
                    searchForNextArm()
                end
           end
       end
    end
    reward/tMax
end