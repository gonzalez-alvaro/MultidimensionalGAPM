# Loading wind data
RESData = CSV.read(pwd()*"/data/RESdata.csv", DataFrame)
    RESnodes = [3,5,7,16,21,23]
    RenG = length(RESnodes)
    SolarData = zeros(RenG,24,365)
    for i in 1:RenG
        global WindData, SolarData
        CitySolar = RESData[:,i]
        SolarData[i,:,:] = reshape(CitySolar, 24, 365)
    end

    SolarData = 2*sum(SolarData, dims=1)[1,:,:]
    S = 1:size(SolarData,2)
    N = length(S)
    T = CircularArray(1:size(SolarData,1))

# Normalized aggregated system load
SystemLoad = convert(Matrix,CSV.read(pwd()*"\\data\\SystemLoad.csv", DataFrame, header =false))

# Bus Data
BusData = CSV.read(pwd()*"\\data\\Buses118.csv", DataFrame)
Nnodes = size(BusData,1) # Number of nodes

# Nodal demand per hour
Pd = 100*collect(SystemLoad[t]*BusData.Pd[n] for n in 1:Nnodes, t in T)
Qd = 100*collect(SystemLoad[t]*BusData.Qd[n] for n in 1:Nnodes, t in T)

# Volatge limits
Vmin = BusData.Vmin
Vmax = BusData.Vmax

# Network Data
NetworkData = CSV.read(pwd()*"\\data\\Branch118.csv", DataFrame)
    STR = zeros(Nnodes,Nnodes) # Flow limit
    B = zeros(Nnodes,Nnodes) # Line susceptance
    for l in 1: size(NetworkData,1)
        fbus = NetworkData[l,:FromBus]
        tbus = NetworkData[l,:ToBus]
        STR[fbus,tbus] = NetworkData[l,:STR]
        STR[tbus,fbus] = NetworkData[l,:STR]
        B[tbus,fbus] = 1/NetworkData[l,:X]
        B[fbus,tbus] = 1/NetworkData[l,:X]
    end

# Generation Data
GenData = CSV.read(pwd()*"\\data\\Gens118.csv", DataFrame)
    G = 1:size(GenData,1)

# Generation Cost Data
CostData = CSV.read(pwd()*"\\data\\CostData.csv", DataFrame)




# Wind data
WindData = convert(Matrix,CSV.read(pwd()*"/data/Windscenarios.csv", DataFrame, header=false))
    WindData = maximum(SolarData)*WindData[1:4:96,:]


# wind spillage and load shedding cost
C_ws = 400
    C_ls = 2000
