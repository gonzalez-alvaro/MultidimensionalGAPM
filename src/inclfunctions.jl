includet(pwd()*"/src/functions/hull2array.jl")
includet(pwd()*"/src/functions/calcSim.jl")
includet(pwd()*"/src/functions/memoryPart.jl")


function give_me_my_name(f::Function)
           return String(Symbol(f))
       end

function getdists()
    # Distance functions from the Distances package
    dists = unique(sort(String.(names(Distances))))
    # Fiter and remove those starting with uppercase and _
    dists = dists[collect(.!(isuppercase(only(dists[n][1])) || dists[n][1] == "_" for n in 1:length(dists)))]

    # functions to remove
    removable = ["bregman" "colwise" "colwise!" "evaluate" "haversine" "mahalanobis" "minkowski" "pairwise" "pairwise!" "peuclidean" "renyi_divergence" "result_type" "rogerstanimoto" "spherical_angle" "sqmahalanobis" "wminkowski" "wcityblock" "weuclidean" "whamming" "wsqeuclidean"]
    for r in removable
        dists = dists[collect(.!(dists[n] == r for n in 1:length(dists)))]
    end

    # weigthed metrics
    weighted = ["wcityblock" "wcityblockvar" "wcityblockinv" "weuclidean" "weuclideanvar" "weuclideaninv" "whamming" "whammingvar" "whamminginv" "wsqeuclidean" "wsqeuclideanvar" "wsqeuclideaninv"]
    for w in weighted
        push!(dists, w)
    end

        return dists
    end


files = ["UCData" "AffProp" "GAPM"  "GAPM_Vec" "mUCEval" "plotAffProp" "UC" "UCEvaluation"];
    for f in files
        includet("functions/"*f*".jl")
    end


function evaluateScenario(ω)
        # println(ω)
        for t in T
            set_normalized_rhs(PowerBalance_Second[t], -(SystemLoad[t] - sum(RES[t,ω])) )
            for g in G
                set_normalized_rhs(PGen_2nd[g,t], Pexp[g,t])
                set_normalized_rhs(PMax2nd[g,t], V[g,t]*GenData.Pmax[g])
                set_normalized_rhs(PMin2nd[g,t], -V[g,t]*GenData.Pmin[g])
                set_normalized_rhs(RplusLim[g,t], Rup[g,t])
                set_normalized_rhs(RminusLim[g,t], Rdw[g,t])
                end
            end

            # Evaluating 2nd stage
            optimize!(mUCEval)
            termination_status(mUCEval)
            OpCost[ω] = JuMP.objective_value.(mUCEval)

            if ALL_DUALS == false # Use only elec balance dual
                λ[ω,:] =  -collect(shadow_price.(PowerBalance_Second[t]) for t in T)
                else
                    λ[ω,:] =
                        [reshape(-collect(shadow_price.(PowerBalance_Second[t]) for t in T),1,:)                                                    reshape(-collect(shadow_price.(PMax2nd[g,t]) for g in G, t in T),1,:)                                                    reshape(-collect(shadow_price.(PMin2nd[g,t]) for g in G, t in T),1,:)                                                    reshape(-collect(shadow_price.(RplusLim[g,t]) for g in G, t in T),1,:)                                                    reshape(-collect(shadow_price.(RminusLim[g,t]) for g in G, t in T),1,:)                                                    reshape(-collect(shadow_price.(Ramps_2ndUp[g,t]) for g in G, t in T),1,:)                                                    reshape(-collect(shadow_price.(Ramps_2ndDw[g,t]) for g in G, t in T),1,:)                                                    reshape(-collect(shadow_price.(PGen_2nd[g,t]) for g in G, t in T),1,:)
                                ]

                end
end

function latex_sci_not( x , ndec; font="sf" )
  xchar = strip(Formatting.sprintf1("%17.$(ndec)e",x))
  data = split(xchar,"e")
  inonzero = findfirst( i -> i != '0', data[2][2:length(data[2])])
  if font == "sf"
    f = "\\textrm{\\sffamily "
    fe = "\\textrm{\\sffamily\\scriptsize "
  else
    f = "{"
    fe = "{"
  end
  if inonzero == nothing
    string = latexstring("$f$(data[1])}")
  else
    if data[2][1] == '-'
      string = latexstring("$f$(data[1])}\\times $f 10}^{$fe$(data[2][1])$(data[2][inonzero+1:length(data[2])])}}")
    else
      string = latexstring("$f$(data[1])}\\times $f 10}^{$fe$(data[2][inonzero+1:length(data[2])])}}")
    end
  end
  return string
    end
