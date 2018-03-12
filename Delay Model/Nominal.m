function [cache_node, ar_list, total_cost] = Nominal(Flows,edge_clouds,access_routers,...
    Wsize,probability,Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish,server)

NF=length(Flows);
cache_node=zeros(NF,1);
ar_list=zeros(NF,1);

probability_buff=probability;
Rspace_buff=Rspace;
Rtotal_buff=Rtotal;

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

total_cost=CostCalculator(cache_node,ar_list,Wsize,probability_buff,...
    Rspace_buff,Fullspace,Rtotal_buff,utilization,graph,alpha,punish,edge_clouds,server);

end

