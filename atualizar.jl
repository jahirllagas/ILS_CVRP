using Random
using Statistics

function atualiza_custo_swap(custo_av,matrix_dist,route_av,pos1,pos2)
    pos0=0
    if pos2==pos1+1 || pos1==pos2+1 #continuos pos1-pos2 or pos2-pos1
        if pos2<pos1
            pos0=pos1
            pos1=pos2
            pos2=pos0
        end
        ANTIGO_pos1=matrix_dist[route_av[pos1-1],route_av[pos1]] + matrix_dist[route_av[pos1],route_av[pos2]]
        ANTIGO_pos2=matrix_dist[route_av[pos2],route_av[pos2+1]]
        NOVO_pos1=matrix_dist[route_av[pos1],route_av[pos2+1]] + matrix_dist[route_av[pos2],route_av[pos1]]
        NOVO_pos2=matrix_dist[route_av[pos1-1],route_av[pos2]]
    else
        ANTIGO_pos1=matrix_dist[route_av[pos1-1],route_av[pos1]] + matrix_dist[route_av[pos1],route_av[pos1+1]]
        ANTIGO_pos2=matrix_dist[route_av[pos2-1],route_av[pos2]] + matrix_dist[route_av[pos2],route_av[pos2+1]]
        NOVO_pos1=matrix_dist[route_av[pos2-1],route_av[pos1]] + matrix_dist[route_av[pos1],route_av[pos2+1]]
        NOVO_pos2=matrix_dist[route_av[pos1-1],route_av[pos2]] + matrix_dist[route_av[pos2],route_av[pos1+1]]
    end
    novo_custo=custo_av+NOVO_pos1+NOVO_pos2-ANTIGO_pos1-ANTIGO_pos2
    return novo_custo
end

function atualiza_custo_relocate(custo_av,matrix_dist,route_av,pos1,pos2)
    pos0=0
    if pos2==pos1+1  || pos1==pos2+1 #continuos pos1-pos2 or pos2-pos1
        if pos2<pos1
            pos0=pos1
            pos1=pos2
            pos2=pos0
        end
        ANTIGO_pos1=matrix_dist[route_av[pos1-1],route_av[pos1]] + matrix_dist[route_av[pos1],route_av[pos2]]
        ANTIGO_pos2=matrix_dist[route_av[pos2],route_av[pos2+1]]
        NOVO_pos1=matrix_dist[route_av[pos1],route_av[pos2+1]] + matrix_dist[route_av[pos2],route_av[pos1]]
        NOVO_pos2=matrix_dist[route_av[pos1-1],route_av[pos2]]

    else
        if pos1<pos2
            ANTIGO_pos1=matrix_dist[route_av[pos1-1],route_av[pos1]] + matrix_dist[route_av[pos1],route_av[pos1+1]]
            ANTIGO_pos2=matrix_dist[route_av[pos2],route_av[pos2+1]]
            NOVO_pos1=matrix_dist[route_av[pos1-1],route_av[pos1+1]]
            NOVO_pos2=matrix_dist[route_av[pos2],route_av[pos1]] + matrix_dist[route_av[pos1],route_av[pos2+1]]
        else
            ANTIGO_pos1=matrix_dist[route_av[pos1-1],route_av[pos1]] + matrix_dist[route_av[pos1],route_av[pos1+1]]
            ANTIGO_pos2=matrix_dist[route_av[pos2-1],route_av[pos2]]
            NOVO_pos1=matrix_dist[route_av[pos1-1],route_av[pos1+1]]
            NOVO_pos2=matrix_dist[route_av[pos1],route_av[pos2]] + matrix_dist[route_av[pos2-1],route_av[pos1]] 
        end               
    end
    novo_custo=custo_av+NOVO_pos1+NOVO_pos2-ANTIGO_pos1-ANTIGO_pos2
    return novo_custo
end

function atualiza_custo_swap_inter(custo_av,matrix_dist,route_av,pos1,cliente2,MAX_DISTANCE)
    INV=true
    ANTIGO_pos1=matrix_dist[route_av[pos1-1],route_av[pos1]] + matrix_dist[route_av[pos1],route_av[pos1+1]]
    NOVO_pos1=matrix_dist[route_av[pos1-1],cliente2] + matrix_dist[cliente2,route_av[pos1+1]]
    novo_custo=custo_av+NOVO_pos1-ANTIGO_pos1
    if novo_custo <=MAX_DISTANCE
        INV=false
    end
    return novo_custo, INV
end

function atualiza_custo_relocate_inter(custo_av1,custo_av2,matrix_dist,route_av1,route_av2,pos1,pos2,MAX_DISTANCE)
    INV=true
    #Rota 1
    ANTIGO_pos1=matrix_dist[route_av1[pos1-1],route_av1[pos1]] + matrix_dist[route_av1[pos1],route_av1[pos1+1]]
    NOVO_pos1=matrix_dist[route_av1[pos1-1],route_av1[pos1+1]]
    #Rota 2
    ANTIGO_pos2=matrix_dist[route_av2[pos2-1],route_av2[pos2]]
    NOVO_pos2=matrix_dist[route_av2[pos2-1],route_av1[pos1]]+matrix_dist[route_av1[pos1],route_av2[pos2]]

    novo_custo1=custo_av1-ANTIGO_pos1+NOVO_pos1
    novo_custo2=custo_av2-ANTIGO_pos2+NOVO_pos2

    if novo_custo1 <=MAX_DISTANCE && novo_custo2 <=MAX_DISTANCE
        INV=false
    end
    return novo_custo1,novo_custo2, INV
end

function atualiza_demanda(d_antigo, d_novo,lista_demand, Demanda,CAPACITY)
    INV=true
    ANTIGO=lista_demand[d_antigo]
    NOVO=lista_demand[d_novo]
    Demanda_nova=Demanda+NOVO-ANTIGO
    if Demanda_nova <=CAPACITY
        INV=false
    end
    return Demanda_nova, INV
end