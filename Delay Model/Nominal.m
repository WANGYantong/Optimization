function solution = Nominal(flows,data,alpha,punish)

edge_clouds=data.edge_cloud;
access_routers=data.access_router;
Wsize=data.W_k;
probability=data.probability;
Rspace=data.Zeta_e;
Rtotal=data.Zeta_t;
graph=data.graph;
server=data.server;

NF=length(flows);
cache_node=zeros(NF,1);
ar_list=zeros(NF,1);

for ii=1:NF
    [flow,ar,list_ec]=FindEcForFlow(probability,access_routers,graph,...
        edge_clouds);
    probability(flow,ar)=0;
    
    cache_node(flow) = list_ec(1);
    ar_list(flow) = ar;
    
    Rspace(cache_node(flow))=Rspace(cache_node(flow))-Wsize(flow);
    Rtotal=Rtotal-Wsize(flow);
    
    if((Rspace(cache_node(flow))<0)||(Rtotal<0))      
        Rspace(cache_node(flow))=Rspace(cache_node(flow))+Wsize(flow);
        Rtotal=Rtotal+Wsize(flow);
        cache_node(flow)=server;
    end   
end

solution.allocation=cache_node;
total_cost=CostCalculator(solution,data,alpha,punish);
solution.total_cost=total_cost;

end

