struct cvrpInstance #<: AbstractInstance
    DIMENSION ::Int64 #vertices
    CAPACITY ::Int64 
    NODES ::Array 
    DEMAND ::Array
    

    function cvrpInstance(filename::String)

        f = open(filename)
        s = read(f, String)
        
        values = split(s,"\n")    
        DIMENSION = parse(Int64, split(values[4],":")[2])
        CAPACITY = parse(Int64, split(values[6],":")[2])
        NODES= Array[]
        DEMAND=Array[]
        for v=8:DIMENSION+7
            g=[parse.(Float64,split(values[v]))]
            append!(NODES,g)
        end
        for v=DIMENSION+9:2*DIMENSION+8
            g=[parse.(Int64,split(values[v]))]
            append!(DEMAND,g)
        end
        new(DIMENSION, CAPACITY, NODES, DEMAND)

    end
end

################################################################################


