## GAPM - UC
## 1. Main GAPM Loop
# Available methods and stats
# GAPM: Adaptative dual-mean comparison
# GAPM_Vec: Full vector comparison
# AffProp: Affinity Propagation
Methods = ["GAPM" "GAPM_Vec" "AffProp"]
# Similarity distances for Affinity Propagation
dists = getdists()
Dict_AffProp = Dict()
ALL_DUALS = false



Meth, mem = "GAPM_Vec", 0
    Meth == "AffProp" ? nN = length(dists) : nN=1
for mem in ["0"]#["0", "1", "Inf"]
    for n in 1:nN
        global Dict_AffProp, RES
        d = dists[n]
        n == 1 ? println("Here we go..") : nothing
        # try
        stat = "L1"
        L = 3

        stepprint = true#(Meth != "AffProp")
        # Parameters for GAPM
        α, γ = 1/2, 1/2
        RES = SolarData[:,1:100]
            N = size(RES,2)
            S = 1:N
            α_0 = α
            μ = mean(RES, dims=2) # Vector with mean RES values
            k, K = 1, 20
            NP = 1
            Ω = 1:NP
            ρ = [1]
            Ind = ones(1,N)'
            R = mean(RES, dims=2)

            Gap = 100
            UB = Inf
            LB = -Inf
            OldGAP = Inf
            GapVec = Array{Float64}[]
            TimeVec = Array{Float64}[]
            Bounds = Array{Float64,2}[]

        # Meth == "AffProp" ? println("Starting UC - "*Meth*": "*stat) : println("Starting UC-"*Meth)
        Meth == "AffProp" ? nothing : println("Starting UC-"*Meth)

            Meth == "GAPM" ? println("α: $(α) - γ: $(γ)") : nothing

        start = now()
            timeT = @elapsed while (k ≤ K)&&(Gap≥0.1)
            global Ind_old, NP_old, Q, duals#, k, ρ, Ω, NP, Ind, Gap, LB, UB, α
            global inds, m#, OldGAP, GapVec, TimeVec, Bounds

            OldGAP = Gap

                if k > 1
                    Ind_old = Ind
                    duals_old = duals
                    if Meth=="GAPM"
                        α = α*γ
                        Ind = GAPM(Ind_old, duals, α_val = α)
                    elseif Meth=="GAPM_Vec"
                        Ind = GAPM_Vec(Ind_old, duals)
                        # Ind2 = Ind
                    elseif Meth=="AffProp"
                        if mem == "Inf"
                            Ind = memoryPart(Ind_old, duals, d, memory = mem)
                        else
                            Ind = memoryPart(duals_old, duals, d, memory = mem)
                            # println()
                            println("$Ind")
                        end

                    end
                    NP = Integer(maximum(Ind))
                    Ω = 1:NP # Scenarios' set
                    R = zeros(length(T),NP)
                    ρ = zeros(NP) # Partition probability
                    R_extreme = zeros(length(T), 2, NP)# Extreme points of partitions
                    for n in 1:NP
                        Ns = sum(Ind .== n)
                        inds = S[Ind[:].==n]
                        R[:,n] = mean(RES[:,inds], dims=2) # mean RES generation in partition
                        ρ[n] = Ns/N
                    end
                    # println("k: $k")
                end
                # println("R: $R")
                V, Pexp, Rup, Rdw, Obj1, LB1, m = UC(Ω, ρ, R)
                LB = max(LB, LB1)

                duals, Q = UCEvaluation(V, Pexp, Rup, Rdw, RES)


                    UB = min(UB, (Obj1 + Q))
                    Gap = (100*(UB-LB)/LB)

                    # Compare the whole vector or its mean
                    Meth == "GAPM" ? duals = mean(duals,dims = 2) : nothing

                t = now()
                    spentTime = 3600*(Dates.hour(t)-Dates.hour(start))+60*(Dates.minute(t)-Dates.minute(start))+(Dates.second(t)-Dates.second(start))+(Dates.millisecond(t)-Dates.millisecond(start))/1000

                    if stepprint == true
                        println("$k & $NP & $(round(LB,digits=3)) & $(round(UB,digits=3)) & $(round(Gap,digits=3)) & $(spentTime) \\\\")
                    end

                GapVec = cat(dims=1, GapVec, [Gap])
                Bounds = cat(dims=1,Bounds, [LB UB])
                TimeVec = cat(dims=1, TimeVec, [spentTime])


            # Controlling Gap stop
            if k>1
                OldGAP ≤ Gap ? break : k+=1
                else
                    Gap = Inf
                    k+=1
                end
            end

            if stepprint == true
                Meth == "GAPM" ? println("α_end: $(α*γ)") : nothing
                Meth == "AffProp" ? println(Meth*": "*d) : println(Meth)
                Meth == "GAPM" ? println("α: $(α_0) - γ: $(γ)") : nothing
            end
        if Meth == "AffProp"
            println()
            println("\\multicolumn{2}{c|}{$(replace(d, "_"=>" "))} & $NP & $(round(Gap,digits=3)) & $(k) & $(round(timeT,digits=2)) \\\\ %$n")
            elseif Meth == "GAPM"
                println()
                println("$α_0 & $γ & $NP & $(round(Gap,digits=3)) & $(k) & $(round(timeT,digits=2)) \\\\")
            elseif Meth == "GAPM_Vec"
                println()
                println("\\multicolumn{6}{c}{GAPM--FullVec} & $NP & $(round(Gap,digits=3)) & $(k) & $(round(timeT,digits=2)) \\\\")
            end

        # Saving in Dictionary
        if Meth == "AffProp"
            Dict_AffProp[d*"_mem$(mem)_Gap"], Dict_AffProp[d*"_mem$(mem)_NP"], Dict_AffProp[d*"_mem$(mem)_TimeVec"] = GapVec, NP, TimeVec
            elseif Meth == "GAPM_Vec"
                Dict_AffProp["GAPMVec_Gap"], Dict_AffProp["GAPMVec_NP"], Dict_AffProp["GAPMVec_TimeVec"] = GapVec, NP, TimeVec
            elseif Meth == "GAPM"
                AlphaGamma = "α$(round(α_0, digits=3))_γ$(round(γ, digits=3))"
                AlphaGamma = replace.((AlphaGamma),"."=>"")
                Dict_AffProp["GAPM_"*AlphaGamma*"_Gap"], Dict_AffProp["GAPM_"*AlphaGamma*"_NP"], Dict_AffProp["GAPM_"*AlphaGamma*"_TimeVec"] = GapVec, NP, TimeVec
            end

        # catch; println("\\multicolumn{2}{c|}{$(replace(d, "_"=>" "))} & -- & -- & -- & -- \\\\ % $d did not work.")
        # end
    end
end



# Plotting Results Gap vs Time
DictAffProp = replace.(keys(Dict_AffProp),"_NP"=>"")
    DictAffProp = replace.((DictAffProp),"_Gap"=>"")
    DictAffProp = replace.((DictAffProp),"_TimeVec"=>"")
    DictAffProp = replace.((DictAffProp),"_mem0"=>"")
    DictAffProp = replace.((DictAffProp),"_mem1"=>"")
    DictAffProp = replace.((DictAffProp),"_memInf"=>"")
    DictAffProp = replace.((DictAffProp),"mem0"=>"")
    unique!(DictAffProp)
    sort!(DictAffProp)
    # show(DictAffProp)

    # collect(DictAffProp[i] for i in 1:length(DictAffProp) if DictAffProp[i][1:4] == "GAPM")
    plotAffProp(Dict_AffProp, chosen = DictAffProp, ymin= 0.0005)

plotAffProp(Dict_AffProp, chosen = DictAffProp, ymin= 0.0005)


DictAffProp[1][1:4]

# Full UC
N = 10
    @elapsed V, Pexp, Rup, Rdw, Obj1, LB = UC(1:N, ones(N)./N, SolarData[:,1:N],printing = 1)
LB


V, Pexp, Rup, Rdw, Obj1, LB = UC(1:1, [1], mean(SolarData,dims=2)[:,:,1], printing=0)
    println("LB: $LB")
    println("LB: $LB")
    # plot!(Pexp')

    plot(sum(Pd,dims=1)', label = "Load", alpha= 0.5)
    plot!(1:24,sum(Pexp,dims=1)'+mean(SolarData,dims=2), alpha = 0.5, labels = "Gen")
heatmap(V')
plot(Pexp')
plot(Rup', label="")
plot(Rdw', label="")

UCEvaluation(V, Pexp, Rup, Rdw, RES)[2]
Obj1

plot!(maximum(SolarData,dims=2), label = "RES")
    hline!([sum(GenData.Pmax)], label = "GenCap")
