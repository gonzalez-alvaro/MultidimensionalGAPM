function boxfig()
    fig = plot()
        phont = "Times New Roman"
        phontsize = 14
        Gaps0 = collect(Dict_AffProp[d*"_mem0_Gap"][end] for d in dists)
        Gaps1 = collect(Dict_AffProp[d*"_mem1_Gap"][end] for d in dists)
        GapsInf = collect(Dict_AffProp[d*"_memInf_Gap"][end] for d in dists)
        Time0 = collect(Dict_AffProp[d*"_mem0_TimeVec"][end] for d in dists)
        Time1 = collect(Dict_AffProp[d*"_mem1_TimeVec"][end] for d in dists)
        TimeInf = collect(Dict_AffProp[d*"_memInf_TimeVec"][end] for d in dists)

        fig = boxplot(["Mem: 0" "Mem: 1" "Mem: Inf"], [Gaps0 Gaps1 GapsInf], leg = false, title = "Gap", line =1, yaxis = :log)
        display(fig)
        fig = boxplot(["Mem: 0" "Mem: 1" "Mem: Inf"], [Time0 Time1 TimeInf], leg = false, title = "Time", line =1)


        display(fig)
        # savefig(fig, figsDir*"/AffProp_mem$(mem).png")
    end
    # plotAffProp(Dict_AffProp, chosen = DictAffProp, ymin= 0.0005)
    boxfig()
