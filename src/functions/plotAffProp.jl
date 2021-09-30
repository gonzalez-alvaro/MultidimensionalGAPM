function plotAffProp(Dict_AffProp, ; chosen=dists, ymin = 0.001, anotar = 0)
    L = 1
    figArray = Any[]
    Kolors = palette(:tab10, length(chosen))
    Xmax = maximum(collect(Dict_AffProp[d*"_TimeVec"][end] for d in chosen))
    # Xmax = maximum(collect(Dict_AffProp[d*"_memInf_TimeVec"][end] for d in dists))

    for k in 1:3
        fig = plot()
        # Legends box
        if k ==4
            fig = hline!([0.001], line = L, label = "0.001 %", legend = :outertop)
            fig = hline!([0.01], line = L, label = "0.01 %")
            fig = hline!([0.1], line = L, label = "0.1 %")
            fig = hline!([1], line = L, label = "1 %")
            fig= scatter!([0],[0], label = "Memory: 0", m = :circle, markersize = 8, color = :white)
            fig= scatter!([0],[0], label = "Memory: 1", m = :rect, markersize = 8, color = :white)
            fig= scatter!([0],[0], label = "Memory: Inf", m = :utriangle, markersize = 8, color = :white)
            else
                fig = hline!([0.001], line = L, label = "")
                fig = hline!([0.01], line = L, label = "")
                fig = hline!([0.1], line = L, label = "")
                fig = hline!([1], line = L, label = "")

            end

        mem = ["0" "1" "Inf"][k]
        for i in 1:length(chosen)
            phont = "Times New Roman"
            phontsize = 14
            d = chosen[i]

            if d == "GAPMVec"
                marquer = :diamond
                elseif (d != "GAPMVec")&&(!issubset([d], dists))
                        marquer = :star
                end

            kol = Kolors[i]
            d0 = d

            if issubset([d0], dists) # Check if its a distance
                d = d0*"_mem$(mem)"
                Gap = Dict_AffProp[d*"_Gap"][end]
                Time = Dict_AffProp[d*"_TimeVec"][end]
                # Markers
                if mem == "0"
                    marquer = :circle
                    elseif mem == "1"
                        marquer = :rect
                    elseif mem == "Inf"
                        marquer = :utriangle
                end

                if (Gap > 0.1)&&(Gap<1)
                    fig = scatter!([Time], [Gap], m = marquer, xlabel = "Time [s]", ylabel = "Gap [%]", yaxis = :log, label = "", ylim=[ymin,100], c = kol, markerstrokewidth=1, markersize = 8)
                    elseif (Gap < 0.1)&&(Gap>10^-6)
                        fig= scatter!([Time], [Gap], m = marquer, xlabel = "Time [s]", ylabel = "Gap [%]", yaxis = :log, label = "", ylim=[ymin,100], c = kol, markerstrokewidth=1, markersize = 8)
                        if (d0 == "jaccard")&&(anotar==1)
                        fig=annotate!((Time, 2*Gap, (d0, :top, phontsize, phont)))
                        elseif (d0 == "whammingvar")&&(anotar==1)
                            fig=annotate!((Time-17, 0.75*Gap, (d0, :left, phontsize, phont)))
                        elseif (anotar==1)
                            fig=annotate!((Time+2, Gap, (d0, :left, phontsize, phont)))
                        end
                    elseif Gap > 1
                        fig= scatter!([Time], [Gap], m = marquer, xlabel = "Time [s]", ylabel = "Gap [%]", yaxis = :log, label = "", ylim=[ymin,100], c = kol, markerstrokewidth=1, markersize = 8)
                            d0 == "kl_divergence" ? dlabel = "kl_div" : nothing
                            d0 == "gkl_divergence" ? dlabel = "gkl_div" : nothing
                            if Time > 20
                                if (d0 == "gkl_divergence")&&(mem=="0")&&(anotar==1)
                                        fig=annotate!((Time-2, 2*Gap, (dlabel, :bottom, phontsize, phont)))
                                    end
                                else
                                    if (d0 == "kl_divergence")&&(mem=="0")&&(anotar==1)
                                        fig=annotate!((Time+10, 1.1*Gap, (dlabel, :left, phontsize, phont)))
                                    end
                                end
                end


            end
            if !(issubset([d0], dists))&&(k==1)
                println()
                println("d: $d")
                Gap = Dict_AffProp[d*"_Gap"][end]
                Time = Dict_AffProp[d*"_TimeVec"][end]
                fig = scatter!([Time], [Gap], m = marquer, xlabel = "Time [s]", ylabel = "Gap [%]", yaxis = :log, label = "", ylim=[ymin,100],  c = kol, markerstrokewidth=1, markersize = 8)
                anotar == 1 ? fig=annotate!((Time+2, Gap, (d0 == "GAPMVec" ? d0 : d0[6:end], :left, phontsize, phont))) : nothing

            end
        end
        fig = xlims!(-5, 1.05*Xmax)
        fig = plot!(size=(1000*upscale, 600*upscale), bottom_margin = -upscale*6mm, top_margin = upscale*0mm, left_margin = -12.5mm, right_margin = -1mm, titlefont=fntlg, guidefont=fntlg, tickfont=fntsm, legendfont=fntsm, guidefontsize=fntsm)
            push!(figArray,fig)

            display(fig)
            # display(fig)
            savefig(fig, figsDir*"/AffProp_$mem.png")
            savefig(fig, figsDir*"/AffProp_$mem.svg")
    end

    # fig1 = plot(figArray..., layout= grid(3,1))#, widths=[0.3 ,0.3, 0.4]))
    end
    plotAffProp(Dict_AffProp, chosen = DictAffProp, ymin= 5*10^(-6))


    # plotAffProp(chosen = DictAffProp, ymin= 0.001)

y = rand(10)
    plot(y)
dists[1][1]=="b"
indexin(dists[1],dists)

filter( x -> x == DictAffProp[1], dists)
issubset(["GAPM"], dists)
maximum(collect(Dict_AffProp[d*"_TimeVec"][end] for d in DictAffProp))
