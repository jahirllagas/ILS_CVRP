using Random
using Statistics

function distance(X,Y)
    dist=((X[1]-Y[1])^2 + (X[2]-Y[2])^2)^0.5
    return dist
end
function aceita_moves(COST_av,COST,max,min)
    Comparacao=[]
    for i in 1:length(COST)
        append!(Comparacao,abs((COST_av[i]-COST[i])/COST[i]))
    end
    alfa_medio=mean(Comparacao)
    if min<=alfa_medio<=max
        return true
    else
        return false
    end
end