using Random
using Statistics
import XLSX
push!(LOAD_PATH, ".")

include("cvrpInstance.jl") #scpInstance contém a estrutura de dados da instância
include("construtivo.jl")
include("moves.jl")
include("avaliar.jl")
include("atualizar.jl")
include("perturbacao.jl")

println(ARGS)
if length(ARGS) < 2
    #print mensagem de erro caso o numero de parametros nao esteja correto
    println("Usage: julia main.jl <scp-instance-file> <moves> <seed>") 
    exit(1)
end

instance_file = ARGS[1] # instance_file recebe o nome do arquivo da instancia
moves = parse(Int64, ARGS[2]) 
# 0: swap/relocate inter
# 1: swap/relocate 
# 2: 0 + 1
seed = parse(Int64,ARGS[3])
instance = cvrpInstance(instance_file) #instancia recebe os dados lidos pelo construtor Instance
name=split(instance_file,".")[1]
name=split(name,"\\")[2]
rng = MersenneTwister(seed) #inicializador do gerador de números aleatórios
startt = time() #inicia o contador de tempo

moves_ILS=[]
if moves==0 || moves==2
    append!(moves_ILS,[1,2])
end
if moves==1 || moves==2
    append!(moves_ILS,[3,4])
end

########################################
# Distancia e Demandas
########################################
matrix_dist=zeros(Float64,instance.DIMENSION,instance.DIMENSION) #Matriz de distancia
lista_demand=[] #Lista de demandas de cada nó
MAX_DISTANCE=30000
for X in instance.NODES
    for Y in instance.NODES
        distancia=round(distance(X[2:3],Y[2:3]),digits=3)
        matrix_dist[floor(Int,X[1]),floor(Int,Y[1])]=distancia
    end
end

for d in instance.DEMAND
    append!(lista_demand,d[2])
end


########################################
# Chamada do metodo construtivo
########################################

COST, ROUTES, D_ROUTES = construtivo(instance.CAPACITY,MAX_DISTANCE, matrix_dist,lista_demand)
COST_opt, ROUTES_opt, D_ROUTES_opt = copy(COST), copy(ROUTES), copy(D_ROUTES)
cost=sum(COST)
println("Custo Construtivo: $cost ") #imprime o custo e a solucao

########################################
# Chamada do metodo busca local
########################################
maximo=0.30
minimo=0.05
max=copy(maximo)
min=copy(minimo)
reduc=0.0001
tempo1 =  time() - startt  #encerra o contador de tempo do construtivo
println("Tempo construtivo: ",  round(tempo1,digits=3))

for r in 1:1000
    achou=true
    while achou==true
        achou=false
        COST_av, ROUTES_av, D_ROUTES_av=copy(COST),copy(ROUTES), copy(D_ROUTES)
        ordem_routes=shuffle(rng,1:length(ROUTES_av))
        
        for pos_rota in ordem_routes
            pos_clientes=shuffle(rng,2:length(ROUTES_av[pos_rota])) # 2: nao muda deposito inicial

            for pos1 in pos_clientes
                ordem_ILS=shuffle(rng,moves_ILS)
                for i in ordem_ILS
                    # chama o metodo de busca local
                    if i==1
                        COST_av, ROUTES_av, achou = swap(matrix_dist, pos1, pos_rota, COST_av, ROUTES_av)
                    
                    elseif i==2
                        COST_av, ROUTES_av, achou = relocate(matrix_dist, pos1, pos_rota, COST_av, ROUTES_av)
                 
                    elseif i==3
                        COST_av, ROUTES_av,D_ROUTES_av, achou = swap_inter(matrix_dist, pos1, pos_rota, COST_av, ROUTES_av,D_ROUTES_av,lista_demand,MAX_DISTANCE, instance.CAPACITY)
                    elseif i==4
                        COST_av, ROUTES_av,D_ROUTES_av, achou = relocate_inter(matrix_dist, pos1, pos_rota, COST_av, ROUTES_av,D_ROUTES_av,lista_demand,MAX_DISTANCE, instance.CAPACITY) 
                    end

                    #Melhorou?
                    if achou==true #Pode ter mesmo custo mas diferente route
                        global COST, ROUTES,D_ROUTES =copy(COST_av), copy(ROUTES_av), copy(D_ROUTES_av)
                        @goto escape_label
                    end
                end
            end
        end
        @label escape_label
    end
    costB=sum(COST)
    rota_vazia=true
    while rota_vazia==true
        rota_vazia=false
        for pos_rota in 1:length(ROUTES)
            if ROUTES[pos_rota]==[1,1] #rota vazia
                splice!(ROUTES,pos_rota)
                splice!(D_ROUTES,pos_rota)
                splice!(COST,pos_rota)
                rota_vazia=true
                break
            end
        end
    end
    #Melhor do otimo?
    if sum(COST) < sum(COST_opt)
        global COST_opt, ROUTES_opt,D_ROUTES_opt  = copy(COST), copy(ROUTES),copy(D_ROUTES)
        global max=copy(maximo)
        global min=copy(minimo)
        #println("Custo Busca Local: $costB - Pase: $r - Opt") #imprime o custo e a solucao
    end
    #println("Custo Busca Local: $costB - Pase: $r - Opt") #imprime o custo e a solucao
    ########################################
    # Perturbacao
    ########################################
    M=0
    add=0
    #error=0
    while M<4
        M=M+1
        add=add+1 #Caso nao consiga valores dentro do rango
        #error=error+1
        COST_av, ROUTES_av, D_ROUTES_av=copy(COST),copy(ROUTES), copy(D_ROUTES)

        pos_rota=rand(rng,1:length(ROUTES_av))
        pos1=rand(rng,2:length(ROUTES_av[pos_rota]))
        i=rand(rng,moves_ILS)
        if i==1
            COST_av, ROUTES_av = swap_p(matrix_dist, pos1, pos_rota, COST_av, ROUTES_av)
        
        elseif i==2
            COST_av, ROUTES_av = relocate_p(matrix_dist, pos1, pos_rota, COST_av, ROUTES_av)
        
        elseif i==3
            COST_av, ROUTES_av,D_ROUTES_av = swap_inter_p(matrix_dist, pos1, pos_rota, COST_av, ROUTES_av,D_ROUTES_av,lista_demand,MAX_DISTANCE, instance.CAPACITY)
        elseif i==4
            COST_av, ROUTES_av,D_ROUTES_av = relocate_inter_p(matrix_dist, pos1, pos_rota, COST_av, ROUTES_av,D_ROUTES_av,lista_demand,MAX_DISTANCE, instance.CAPACITY) 
        end
            
        if M==4
            if aceita_moves(COST_av,COST,max,min)==false
                M=0
            else
                global COST, ROUTES,D_ROUTES =copy(COST_av), copy(ROUTES_av), copy(D_ROUTES_av)
                global max=max-reduc
                global min=min-reduc
            end
        end
        if add >500
            add=0
            global max=max+0.05
        end
        #=if error >100
            exit()
        end=#
    end
end
tempo2 =  time() - startt
println("Tempo Total: ",  round(tempo2,digits=3))
println(sum(COST_opt))

########################################
# Distancia e Demandas (avaliar se nao mudou os valores nas iteracoes)
########################################
matrix_dist=zeros(Float64,instance.DIMENSION,instance.DIMENSION) #Matriz de distancia
lista_demand=[] #Lista de demandas de cada nó
MAX_DISTANCE=30000
for X in instance.NODES
    for Y in instance.NODES
        distancia=round(distance(X[2:3],Y[2:3]),digits=3)
        matrix_dist[floor(Int,X[1]),floor(Int,Y[1])]=distancia
    end
end

for d in instance.DEMAND
    append!(lista_demand,d[2])
end
########################################
# Avaliacao
########################################
COST_avaliado=0
Demanda_avaliada=[]
for route in ROUTES_opt
    d=0
    for c in 1:length(route)
        if c !=1
            global COST_avaliado=COST_avaliado + matrix_dist[route[c-1],route[c]]
        end
        d = d+lista_demand[route[c]]
    end
    append!(Demanda_avaliada,d)
end
println(COST_avaliado)
println(Demanda_avaliada)

########################################
# Salva Resultados
########################################
if isfile("Resultados_$name.xlsx")
    XLSX.openxlsx("Resultados_$name.xlsx", mode="rw") do xf
        sheet = xf[1]
        celda0="A1"
        celda1="A1"
        celda2="A1"
        celda3="A1"
        celda4="A1"    
        for lin in 1:100
            if (ismissing(sheet["A"*string(lin+1)])) 
                celda0 = "A"*string(lin+1)
                celda1 = "B"*string(lin+1)
                celda2 = "C"*string(lin+1)
                celda3 = "D"*string(lin+1)
                celda4 = "E"*string(lin+1)
                break
            end
        end
        sheet[celda0] = ARGS[1]
        sheet[celda1] = round(sum(COST_opt),digits=3)
        sheet[celda2] = length(ROUTES_opt)
        sheet[celda3] = tempo2
        sheet[celda4] = seed
    end
else
    XLSX.openxlsx("Resultados_$name.xlsx", mode="w") do xf
        sheet = xf[1]
        celda0="A1"
        celda1="B1"
        celda2="C1"
        celda3="D1"
        celda4="E1"    

        sheet[celda0] = ARGS[1]
        sheet[celda1] = round(sum(COST_opt),digits=3)
        sheet[celda2] = length(ROUTES_opt)
        sheet[celda3] = tempo2
        sheet[celda4] = seed
    end
end