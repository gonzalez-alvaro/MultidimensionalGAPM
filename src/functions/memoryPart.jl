## SCENARIO PARTITION

function memoryPart(Vec_old, duals, d; memory = 0.)
    # If memory = 1: Vec_old = duals_old
    # If memory = Inf: Vec_old = Ind_old
    if memory == "0"
        Sim = calcSim(duals, d, S)
        Ind_new = AffProp(Sim)

    else
        if memory == "1"
            # Calculating partitions for the duals on the previos iteration
            Sim_old = calcSim(Vec_old, d, S)
            # Calculating new subpartition indices
            Vec_old = AffProp(Sim_old)
        end
        DualPart = Array{Float64}[]
            locsPart = Array{Float64}[]
            N = size(duals,1)
            NT = size(duals,2)
            NP = maximum(Vec_old)
            Ind_new = zeros(N)
            NsubParts = 1

        Scenarios = [duals Vec_old collect(1:N)]

        for p in 1:NP
            DualPart = Scenarios[Scenarios[:,NT+1].==p,:] # Accessing the Vec_old column
                sizePart = size(DualPart,1)
                locsPart = Integer.(DualPart[:,end])# indices of scenarios in subpart

            if sizePart > 1
                # Calculating Distance within partition
                Sim = calcSim(DualPart[:,1:NT], d, 1:sizePart)
                # Calculating new subpartition indices
                clustInds = AffProp(Sim)

                # Assigning new subpart indices pre-clustering
                Ind_new[locsPart] .= NsubParts
                # Reference value of subpartition/ first value
                ref = clustInds[1]

                for n in 2:sizePart
                    # Comparing sub-assignments
                    if clustInds[n] != ref
                        NsubParts += 1
                        ref = clustInds[n] # Reference (1st) value for the partition
                    end
                    Ind_new[locsPart[n]] = NsubParts
                end
            else
                Ind_new[locsPart] .= NsubParts
            end
            NsubParts += 1
        end
    end
    return Integer.(Ind_new)
end
