"""
Exact and Tractable Algorithm for Solving the Two-stage Stochastic Unit Commitment Problem

Alvaro Gonzalez - alvaro.gonzalez@skolkovotech.ru
Moscow, July 2021
"""

## 0. SETUP
# 0.0. Setting working directory
cur_path, fileName = splitdir(Base.source_path())
  cd(cur_path[1:end-4])
  println()
  println("The current working directory is: "*pwd())

    # 0.1. Running setup file
    ENV["GRB_LICENSE_FILE"] = "C:\\Users\\ajcas\\gurobi.lic"
    using Revise
    includet("setup.jl")
