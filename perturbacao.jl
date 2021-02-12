using Random
using Statistics
#Opcao 1
#=function perturbacao()
    clientes_fora=[]
    for pos_rota in 1:length(ROUTES)
        par=length(ROUTES[pos_rota])
        MEDIA=COST[pos_rota]/(par-2) # media= custo/num_clientes
        if par%2==1
            par=par+1
        end

        COST_var=0
        for c in [2*i-1 for i in 2:par/2]
            media_c=(matrix_dist[c-2,c-1] + matrix_dist[c-1,c])/2 #Media partional 
            if media_c>MEDIA
                append!(clientes_fora,c-1) #eliminamos eixo central da particao
                ANTIGO=media_c*2
                NOVO=matrix_dist[c-2,c]
                COST_var=COST_var+NOVO-ANTIGO
end=#

#Opcao 2
function swap_p(matrix_dist, pos1, pos_rota, COST_av, ROUTES_av)

    RTS_av= copy(ROUTES_av)
    route_av= copy(RTS_av[pos_rota])

    CST_av=copy(COST_av)
    custo_av=copy(CST_av[pos_rota])

    if pos1 != length(route_av) #Nao muda deposito final
        ordem_cliente2=shuffle(rng,2:length(route_av)-1)
        for pos2 in ordem_cliente2
            if pos2!=pos1
                route_av= copy(RTS_av[pos_rota])
                custo_av=copy(CST_av[pos_rota])
                novo_custo=atualiza_custo_swap(custo_av,matrix_dist,route_av,pos1,pos2)
                route_av[pos1],route_av[pos2] = route_av[pos2], route_av[pos1] #troca
                RTS_av[pos_rota]=route_av 
                CST_av[pos_rota]=novo_custo
                return CST_av, RTS_av
            end
        end
    end   
    return COST_av, ROUTES_av
end

function relocate_p(matrix_dist, pos1, pos_rota, COST_av, ROUTES_av) #error en calculo

    RTS_av= copy(ROUTES_av)
    route_av= copy(RTS_av[pos_rota])

    CST_av=copy(COST_av)
    custo_av=copy(CST_av[pos_rota])

    if pos1 != length(route_av) #Nao muda deposito final
        ordem_cliente2=shuffle(rng,2:length(route_av)-1)

        for pos2 in ordem_cliente2
            if pos2!=pos1
                route_av= copy(RTS_av[pos_rota])
                custo_av=copy(CST_av[pos_rota])
                novo_custo=atualiza_custo_relocate(custo_av,matrix_dist,route_av,pos1,pos2)
                c=splice!(route_av,pos1) #remove
                insert!(route_av,pos2,c) #insert
                RTS_av[pos_rota]=route_av 
                CST_av[pos_rota]=novo_custo
                return CST_av, RTS_av
            end
        end
    end
    return COST_av, ROUTES_av
end

function swap_inter_p(matrix_dist, pos1, pos_rota, COST_av, ROUTES_av,D_ROUTES_av,lista_demand,MAX_DISTANCE, CAPACITY)

    RTS_av= copy(ROUTES_av)
    CST_av=copy(COST_av)
    DMD_av=copy(D_ROUTES_av)

    if pos1 != length(RTS_av[pos_rota]) #Nao muda deposito final
        for pos_rota2 in 1:length(ROUTES_av)
            if ROUTES_av[pos_rota2] != ROUTES_av[pos_rota]
                ordem_cliente2=shuffle(rng,2:length(RTS_av[pos_rota2])-1)
                for pos2 in ordem_cliente2
                    if pos2!=pos1
                        route_av1, route_av2= copy(RTS_av[pos_rota]), copy(RTS_av[pos_rota2])
                        custo_av1, custo_av2= copy(CST_av[pos_rota]), copy(CST_av[pos_rota2])

                        novo_custo1,INV1=atualiza_custo_swap_inter(custo_av1,matrix_dist,route_av1,pos1,route_av2[pos2],MAX_DISTANCE) #Tmbm avalia distancia
                        novo_custo2,INV2=atualiza_custo_swap_inter(custo_av2,matrix_dist,route_av2,pos2,route_av1[pos1],MAX_DISTANCE)
                        #Nao aceita solucoes inviaveis
                        if INV1 || INV2
                            @goto fim
                        end

                        demanda1,INV3=atualiza_demanda(route_av1[pos1],route_av2[pos2],lista_demand, D_ROUTES_av[pos_rota],CAPACITY)#Tmbm avalia Limite de capacidade
                        demanda2,INV4=atualiza_demanda(route_av2[pos2], route_av1[pos1],lista_demand, D_ROUTES_av[pos_rota2],CAPACITY)
                        #Nao aceita solucoes inviaveis
                        if INV3 || INV4
                            @goto fim
                        end
                        route_av1[pos1],route_av2[pos2] = route_av2[pos2], route_av1[pos1] #troca

                        RTS_av[pos_rota], RTS_av[pos_rota2]=route_av1,route_av2
                        CST_av[pos_rota], CST_av[pos_rota2]=novo_custo1, novo_custo2
                        DMD_av[pos_rota], DMD_av[pos_rota2]=demanda1, demanda2                
                        return CST_av, RTS_av,DMD_av
                    end
                    @label fim
                end
            end
        end
    end
    return COST_av, ROUTES_av,D_ROUTES_av
end

function  relocate_inter_p(matrix_dist, pos1, pos_rota, COST_av, ROUTES_av,D_ROUTES_av,lista_demand,MAX_DISTANCE, CAPACITY)


    RTS_av= copy(ROUTES_av)
    CST_av=copy(COST_av)
    DMD_av=copy(D_ROUTES_av)

    if pos1 != length(RTS_av[pos_rota]) #Nao muda deposito final
        for pos_rota2 in 1:length(ROUTES_av)
            if ROUTES_av[pos_rota2] != ROUTES_av[pos_rota]
                ordem_cliente2=shuffle(rng,2:length(RTS_av[pos_rota2]))
                for pos2 in ordem_cliente2
                    route_av1, route_av2= copy(RTS_av[pos_rota]), copy(RTS_av[pos_rota2])
                    custo_av1, custo_av2= copy(CST_av[pos_rota]), copy(CST_av[pos_rota2])

                    novo_custo1,novo_custo2, INV1=atualiza_custo_relocate_inter(custo_av1,custo_av2,matrix_dist,route_av1,route_av2,pos1,pos2,MAX_DISTANCE) #Tmbm avalia distancia
                    #Nao aceita solucoes inviaveis
                    if INV1
                        @goto fim
                    end

                    demanda1,INV2=atualiza_demanda(route_av1[pos1],1,lista_demand, D_ROUTES_av[pos_rota],CAPACITY)#Tmbm avalia Limite de capacidade
                    demanda2,INV3=atualiza_demanda(1, route_av1[pos1],lista_demand, D_ROUTES_av[pos_rota2],CAPACITY)
                    #Nao aceita solucoes inviaveis
                    if INV2 || INV3
                        @goto fim
                    end

                    c=splice!(route_av1,pos1) #remove
                    insert!(route_av2,pos2,c) #insert

                    RTS_av[pos_rota], RTS_av[pos_rota2]=route_av1,route_av2
                    CST_av[pos_rota], CST_av[pos_rota2]=novo_custo1, novo_custo2
                    DMD_av[pos_rota], DMD_av[pos_rota2]=demanda1, demanda2                
                    return CST_av, RTS_av,DMD_av

                    @label fim
                end
            end
        end
    end

    return COST_av, ROUTES_av,D_ROUTES_av
    
end