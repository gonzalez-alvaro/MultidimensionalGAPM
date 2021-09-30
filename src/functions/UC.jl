## UC Model
function UC(Ω, ρ, RES; printing = 0)
    mUC = Model(() -> Gurobi.Optimizer(GUROBI_ENV))
    set_optimizer_attribute(mUC, "OutputFlag", printing)

        ### Variables
        # 1st stage
        @variables(mUC, begin
            v[G,T], (Bin) # Unit state
            0.0 ≤ c_su[G,T] # start-up cost
            0.0 ≤ c_rc[G,T] # reserve capacity cost
            0.0 ≤ obj1
            0. ≤ p_exp[g in G,T] ≤ GenData.Pmax[g] # Expected generation
            0. ≤ r_up[g in G,T] ≤ GenData.Rup[g] # Upward reserve capacity
            0. ≤ r_dw[g in G,T] ≤ GenData.Rdw[g] # Downward reserve capacity
            end)

            # 2nd stage
            @variables(mUC, begin
                0. ≤ p[g in G,Ω,T] ≤ GenData.Pmax[g] # Real-time generation
                0. ≤ r_p[g in G,Ω,T] #≤ GenData.Rplus[g] # Real-time up reserve
                0. ≤ r_m[g in G,Ω,T] #≤ GenData.Rminus[g] # Real-time down reserve
                0. ≤ l_s[t in T, Ω] ≤ sum(Pd,dims=1)[t] # load shedding
                0. ≤ w_s[t in T, ω in Ω] ≤ RES[t,ω] # wind spillage
                0. ≤ Θ[Ω] # operation costs

            end)

        ### Constraints
        #### 1st stage
            # Power limits
            @constraints(mUC, begin
                PMax[g in G, t in T], p_exp[g,t] + r_up[g,t]≤ v[g,t]*GenData.Pmax[g]
                PMin[g in G, t in T], p_exp[g,t] - r_dw[g,t]≥ v[g,t]*GenData.Pmin[g]
                RupLim[g in G, ω in Ω, t in T], r_up[g,t] ≤ v[g,t]*GenData.Rup[g]
                RdwLim[g in G, ω in Ω, t in T], r_dw[g,t] ≤ v[g,t]*GenData.Rdw[g]
                end)
            # Costs
            @constraint(mUC, obj1 == sum(GenData.Cg[g]*p_exp[g,t]
                                + c_su[g,t] + c_rc[g,t] for g in G, t in T))

            @constraints(mUC, begin
                CostReserveCap[g in G, t in T],
                        c_rc[g,t] == r_up[g,t]*GenData.Cup[g] + r_dw[g,t]*GenData.Cdw[g]
                #
                CostSU[g in G, t in T],
                        c_su[g,t] ≥ GenData.Cstart[g]*(v[g,t] - v[g,T[t-1]])
                            end)

            # Minimum Online & Offline Times
            @constraints(mUC, begin
                MinOn[g in G, t in T],
                    sum(v[g,n] for n in t:min(t+GenData.UT[g]-1,24)) ≥ GenData.UT[g]*(v[g,t]-v[g,T[t-1]])

                MinOff[g in G, t in T],
                    sum(1-v[g,n] for n in t:min(t+GenData.DT[g]-1,24)) ≥ GenData.DT[g]*(v[g,T[t-1]]-v[g,t])
                end)

            #### 2nd stage
            # Power balance
            @constraint(mUC, PowerBalance_Second[ω in Ω, t in T],
                                sum(Pd,dims=1)[t] - l_s[t,ω]== RES[t,ω] + sum(p[:,ω,t]) - w_s[t,ω])

            # Power limits
            @constraints(mUC, begin
                PMax2nd[g in G, ω in Ω, t in T], p[g,ω,t] ≤ v[g,t]*GenData.Pmax[g]
                PMin2nd[g in G, ω in Ω, t in T], p[g,ω,t] ≥ v[g,t]*GenData.Pmin[g]
                RplusLim[g in G, ω in Ω, t in T], r_p[g,ω,t] ≤ r_up[g,t]
                RminusLim[g in G, ω in Ω, t in T], r_m[g,ω,t] ≤ r_dw[g,t]
                Ramps_2nd[g in G, ω in Ω, t in T], -GenData.Rdw[g] ≤ p[g,ω,t] - p[g,ω,T[t-1]] ≤ GenData.Rup[g]

                end)

            # Generated Power
            @constraint(mUC, PGen_2nd[g in G, ω in Ω, t in T],
                    p[g,ω,t] == p_exp[g,t] + r_p[g,ω,t] - r_m[g,ω,t])

            # Total Cost
            @constraint(mUC, Cost_2nd[ω in Ω],
                    Θ[ω] == sum(C_ls*l_s[t,ω] + C_ws*w_s[t,ω] + sum(GenData.Cplus[g]*r_p[g,ω,t] - GenData.Cminus[g]*r_m[g,ω,t] for g in G) for t in T)
                    )

        ### Objective
        @objective(mUC, Min, obj1 + sum(ρ[ω]*Θ[ω] for ω in Ω))

        optimize!(mUC)
        # println("Gap: $(MOI.get(mUC, MOI.RelativeGap()))")

    V = JuMP.value.(v)
        V= collect(V[i,j] for i in G, j in T)
            Pexp = (JuMP.value.(p_exp))
            Pexp= collect(Pexp[i,j] for i in G, j in T)
            Rup = (JuMP.value.(r_up))
            Rup= collect(Rup[i,j] for i in G, j in T)
            Rdw = (JuMP.value.(r_dw))
            Rdw= collect(Rdw[i,j] for i in G, j in T)
            Obj1 = JuMP.value.(obj1)
            LB = JuMP.objective_value.(mUC)


            # println("l_s:")
            # println(C_ls*sum(JuMP.value.(l_s)))
            # println("w_s")
            # println(C_ws*sum(JuMP.value.(w_s)))
            # println("Reserves:")
            # println(sum(sum(GenData.Cplus[g]*JuMP.value.(r_p[g,ω,t]) - GenData.Cminus[g]*JuMP.value.(r_m[g,ω,t]) for g in G) for t in T, ω in Ω))

    return V, Pexp, Rup, Rdw, Obj1, LB, mUC

    end
