using Random
using Statistics


function construtivo(CAPACITY,MAX_DISTANCE, matrix_dist,lista_demand)
    ordem_clientes=shuffle(rng,2:length(lista_demand))
    #Inicio cria rota vazia apenas com deposito
    ROUTES=[]
    #Salva a demanda das rotas
    D_ROUTES=[]
    #Salva custo
    CUSTO=[]
    for c in ordem_clientes
        if  isempty(ROUTES)
            #Adiciona primeiro cliente aleatorio
            append!(ROUTES,[[1,c]])
            append!(D_ROUTES, lista_demand[c])
            append!(CUSTO,matrix_dist[1,c])
        else
            min_dist= Inf
            pos=0
            demanda=0
            for pos_route in 1:length(ROUTES)
                dist_av=CUSTO[pos_route] + matrix_dist[last(ROUTES[pos_route]),c] #Custo atual + novo cliente
                demanda_av=D_ROUTES[pos_route] + lista_demand[c] #Demanda atual + novo cliente
                if (demanda_av <= CAPACITY && dist_av <= MAX_DISTANCE) #Capacidade limitada
                    if dist_av<=min_dist
                        min_dist=dist_av
                        demanda=demanda_av
                        pos= pos_route
                    end
                end
            end
            if pos==0
                append!(ROUTES,[[1,c]])
                append!(D_ROUTES, lista_demand[c])
                append!(CUSTO,matrix_dist[1,c])
            else
                D_ROUTES[pos]= demanda
                CUSTO[pos]= min_dist
                append!(ROUTES[pos],c)
            end
        end
    end
    for pos_route in 1:length(ROUTES)
        dist= CUSTO[pos_route]+ matrix_dist[last(ROUTES[pos_route]),1]
        CUSTO[pos_route]= dist
        append!(ROUTES[pos_route],1)
    end
    return CUSTO, ROUTES, D_ROUTES
end
#=
function construtivo2(CAPACITY,MAX_DISTANCE, matrix_dist,lista_demand)
    ordem_clientes=shuffle(rng,2:length(lista_demand))
    #Inicio cria rota vazia apenas com deposito
    ROUTES=[]
    #Salva a demanda das rotas
    D_ROUTES=[]
    #Salva custo
    CUSTO=[]
    for c in ordem_clientes
        if  isempty(ROUTES)
            #Adiciona primeiro cliente aleatorio
            append!(ROUTES,[[1,c]])
            append!(D_ROUTES, lista_demand[c])
            append!(CUSTO,matrix_dist[1,c])
        else
            min_dist= matrix_dist[1,c]
            pos=0
            demanda=0
            for pos_route in 1:length(ROUTES)
                dist_av=CUSTO[pos_route] + matrix_dist[last(ROUTES[pos_route]),c] #Custo atual + novo cliente
                demanda_av=D_ROUTES[pos_route] + lista_demand[c] #Demanda atual + novo cliente
                if (demanda_av <= CAPACITY && dist_av <= MAX_DISTANCE) #Capacidade limitada
                    if dist_av<=min_dist
                        min_dist=dist_av
                        demanda=demanda_av
                        pos= pos_route
                    end
                end
            end
            if pos==0
                append!(ROUTES,[[1,c]])
                append!(D_ROUTES, lista_demand[c])
                append!(CUSTO,matrix_dist[1,c])
            else
                D_ROUTES[pos]= demanda
                CUSTO[pos]= min_dist
                append!(ROUTES[pos],c)
            end
        end
    end
    for pos_route in 1:length(ROUTES)
        dist= CUSTO[pos_route]+ matrix_dist[last(ROUTES[pos_route]),1]
        CUSTO[pos_route]= dist
        append!(ROUTES[pos_route],1)
    end
    return CUSTO, ROUTES, D_ROUTES
end=#