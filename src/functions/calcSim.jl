function calcSim(duals, dist, S)
    if dist == "L1"
        # Measures L1 distance - Minkowski with p=1
        # https://juliahub.com/docs/LSHFunctions/nLuMy/0.1.2/similarities/lp_distance/
        Sim = collect(ℓ1(duals[i,:],duals[j,:]) for i in S, j in S)
    elseif dist == "L2"
        # Measures L2 distance - Minkowski with p=1
        # https://juliahub.com/docs/LSHFunctions/nLuMy/0.1.2/similarities/lp_distance/
        Sim = collect(ℓ2(duals[i,:],duals[j,:]) for i in S, j in S)
    elseif dist == "jaccard"
        # Measures Jaccard similarity
        # https://juliahub.com/docs/LSHFunctions/nLuMy/0.1.2/similarities/jaccard/
        Sim = collect(LSHFunctions.jaccard(duals[i,:],duals[j,:]) for i in S, j in S)
    elseif dist in ["wcityblock" "weuclidean" "whamming" "wsqeuclidean"]
        # Weighted metrics with equal weights
        W = ones(length(T))
        Sim = collect(Distances.eval(Symbol(dist))(duals[i,:],duals[j,:],W)+0. for i in S, j in S)
    elseif dist in ["wcityblockvar" "weuclideanvar" "whammingvar" "wsqeuclideanvar"]
        # Weighted metrics with weights proportional to variance
        dist = dist[1:end-3] # Renaming to use proper function
        W = var(duals, dims=1)
        Sim = collect(Distances.eval(Symbol(dist))(duals[i,:],duals[j,:],W)+0. for i in S, j in S)
    elseif dist in ["wcityblockinv" "weuclideaninv" "whamminginv" "wsqeuclideaninv"]
        dist = dist[1:end-3] # Renaming to use proper function
        # Weighted metrics with weights inverse to variance
        VAR = var(duals, dims=1)
        W = 1  .- VAR./maximum(VAR)
        Sim = collect(Distances.eval(Symbol(dist))(duals[i,:],duals[j,:],W)+0. for i in S, j in S)
    else
        Sim = collect(Distances.eval(Symbol(dist))(duals[i,:],duals[j,:])+0. for i in S, j in S)
    end
    return Sim
end
