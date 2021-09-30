## SCENARIO PARTITION
function GAPM(Ind_old, duals; α_val = 0.)
    dualRange = maximum(duals)-minimum(duals)
    MaxDiff = α_val*dualRange # Maximum difference between scenario duals

    NP = maximum(Ind_old)

    Scenarios = [duals Ind_old collect(1:N)]

    Ind,NsubParts = ones(N), 1

    for p in 1:NP
        DualPart = Scenarios[Scenarios[:,2].==p,:]
        DualPart=DualPart[sortperm(DualPart[:, 1]), :]
        sizePart = size(DualPart, 1)
        Ind[Integer(DualPart[1,3])] = NsubParts
        ref = DualPart[1,1]
        for n in 2:sizePart
            # Evaluating distance between duals
            if abs(DualPart[n,1] - ref) > MaxDiff
                NsubParts += 1
                ref = DualPart[n,1] # Reference (1st) value for the partition
            end
            Ind[Integer(DualPart[n,3])] = NsubParts
        end
        NsubParts += 1
    end
        return Integer.(Ind)
end
