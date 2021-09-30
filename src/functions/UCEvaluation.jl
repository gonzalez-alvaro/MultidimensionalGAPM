# UCEvaluation: UC Evaluation by scenarios
function UCEvaluation(V, Pexp, Rup, Rdw, RESData)
    OpCost = 0.
    ALL_DUALS ? NC = 7 : NC =0 # Are we considering all duals or not?
    λ = zeros(N, NC*length(G)*length(T)+length(T))
    m = m_UCEval(V, Pexp, Rup, Rdw, RESData)
    for ω in 1:N
        for t in T
            set_normalized_rhs(m[:PowerBalance_Second][t], -(sum(Pd,dims=1)[t] - RES[t,ω]) )
            set_normalized_rhs(m[:Spillage_Limits][t], RES[t,ω])

            end

            # Evaluating 2nd stage
            optimize!(m)
            OpCost += JuMP.objective_value.(m)

            if ALL_DUALS == false # Use only elec balance dual
                λ[ω,:] =  -collect(shadow_price.(m[:PowerBalance_Second][t]) for t in T)
                else
                    λ[ω,:] =
                        [reshape(-collect(shadow_price.(m[:PowerBalance_Second][t]) for t in T),1,:)                                                    reshape(-collect(shadow_price.(m[:PMax2nd][g,t]) for g in G, t in T),1,:)                                                    reshape(-collect(shadow_price.(m[:PMin2nd][g,t]) for g in G, t in T),1,:)                                                    reshape(-collect(shadow_price.(m[:RplusLim][g,t]) for g in G, t in T),1,:)                                                    reshape(-collect(shadow_price.(m[:RminusLim][g,t]) for g in G, t in T),1,:)                                                    reshape(-collect(shadow_price.(m[:Ramps_2ndUp][g,t]) for g in G, t in T),1,:)                                                    reshape(-collect(shadow_price.(m[:Ramps_2ndDw][g,t]) for g in G, t in T),1,:)                                                    reshape(-collect(shadow_price.(m[:PGen_2nd][g,t]) for g in G, t in T),1,:)
                                ]

                end
        end
    # return λ, OpCost
    # end

    return λ, OpCost/N
    end
