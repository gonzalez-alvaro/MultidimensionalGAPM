## SCENARIO PARTITION
function GAPM_Vec(Ind_old, duals; α_val = 0.)
    NP = maximum(Ind_old)

    Scenarios = [Ind_old collect(1:N)]
        Ind,NsubParts = ones(N), 1

        dist = collect(abs(duals[i,t]-duals[j,t]) for i in 1:N, j in 1:N, t in T)
    for p in 1:NP
        DualPart = Scenarios[Scenarios[:,1].==p,:]

        sizePart = size(DualPart, 1)
        Rem = Integer.(DualPart[:,2]) # Remaining scenarios to assign
        while length(Rem)≥1

            indsP = collect(i for i in 2:length(Rem) if maximum(dist[Rem[1],Rem[i],:])≤α_val)
            indsP = [Rem[1]; Rem[indsP]]

            Ind[indsP] .= NsubParts

            RemInds = collect(i for i in 1:length(Rem) if !(Rem[i] in indsP))
            Rem = Rem[RemInds]
            NsubParts += 1
        end
        end
    return Integer.(Ind)
end
