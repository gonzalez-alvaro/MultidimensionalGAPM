# UCEvaluation: UC Evaluation by scenarios
function m_UCEval(v, pexp, rup, rdw, RESData)

    NetLoad = collect(sum(Pd,dims=1)[t] - sum(mean(RESData[t,:])) for t in T)

    mUCEval = Model(() -> Gurobi.Optimizer(GUROBI_ENV))
        set_optimizer_attribute(mUCEval, "OutputFlag", 0)

        # Variables
        @variables(mUCEval, begin
            0. ≤ p[g in G,T] ≤ GenData.Pmax[g]
            0. ≤ r_p[G,T]
            0. ≤ r_m[G,T]
            0. ≤ l_s[t in T] ≤ sum(Pd,dims=1)[t] # load shedding
            0. ≤ w_s[t in T]  # wind spillage
        end)

        # Constraints
        # 2nd stage
        # Power balance
        @constraint(mUCEval, PowerBalance_Second[t in T],
                            NetLoad[t] - l_s[t]== sum(p[:,t]) - w_s[t])

            # Power limits
            @constraints(mUCEval, begin
                PMax2nd[g in G, t in T], p[g,t] ≤ v[g,t]*GenData.Pmax[g]
                PMin2nd[g in G, t in T], p[g,t] ≥ v[g,t]*GenData.Pmin[g]
                RplusLim[g in G, t in T], r_p[g,t] ≤ rup[g,t]
                RminusLim[g in G, t in T], r_m[g,t] ≤ rdw[g,t]
                Ramps_2ndUp[g in G, t in T], p[g,t] - p[g,T[t-1]] ≤ GenData.Rup[g]
                Ramps_2ndDw[g in G, t in T], -GenData.Rdw[g] ≤ p[g,t] - p[g,T[t-1]]
                Spillage_Limits[t in T], w_s[t] ≤ mean(RESData[t,:])

                end)

            # Generated Power
            @constraint(mUCEval, PGen_2nd[g in G, t in T],
                    p[g,t] - r_p[g,t] + r_m[g,t] == pexp[g,t])

        ### Objective
        @objective(mUCEval, Min, sum(C_ls*l_s[t] + C_ws*w_s[t] + sum(GenData.Cplus[g]*r_p[g,t] - GenData.Cminus[g]*r_m[g,t] for g in G) for t in T) )


    optimize!(mUCEval)
    return mUCEval
end
