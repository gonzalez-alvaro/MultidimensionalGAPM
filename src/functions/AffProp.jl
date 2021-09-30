# Affinity Propagation clustering
# https://juliastats.org/Clustering.jl/stable/affprop.html#Affinity-Propagation-1

function AffProp(Sim)
    # If it fails to cluster, then they all stay in the same cluster
    Ind = ones(size(Sim,1))
    try
        AFFPROP = affinityprop(100*Sim) # Affinity propagation clustering
        Ind = AFFPROP.assignments
    catch
    end

    return Ind
end
