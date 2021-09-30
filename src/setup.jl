# SETUP FILE
using CircularArrays, Clustering, CSV, DataFrames, Dates, Distances, Distributions, JuMP, Formatting, Gurobi, LaTeXStrings, LSHFunctions, LinearAlgebra, Polyhedra, Plots, Printf, QHull, Revise,  Statistics
    gr()
    const GUROBI_ENV = Gurobi.Env()

    # Include useful functions
    includet("inclfunctions.jl")


    ## Plot settings
    using Plots.PlotMeasures
    upscale = 1 #8x upscaling in resolution
    fntsm = Plots.font("Times New Roman", pointsize=round(12.0*upscale))
    fntlg = Plots.font("Times New Roman", pointsize=round(16*upscale))
    default(thickness_scaling=2, titlefont=fntlg, guidefont=fntlg, tickfont=fntsm, legendfont=fntsm,
          guidefontsize=fntsm, foreground_color_legend = nothing,
          background_color_legend = nothing, linewidth=12*upscale, foreground_color_axis=:black)
    default(size=(1600*upscale,900*upscale)) #Plot canvas size
    default(bottom_margin = -upscale*3mm, left_margin = -10mm, right_margin = -10mm, top_margin = upscale*0mm)
    figsDir = "C:\\Users\\ajcas\\Dropbox\\Aplicaciones\\Overleaf\\PSCC2022. Partition-Based DRO UC\\figs"
