function [cache_node, ar_list, total_cost] = Nominal(Flows,edge_clouds,access_routers,...
    Wsize,probability,Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish)

NF=length(Flows);
cache_node=zeros(NF,1);
ar_list=zeros(NF,1);

probability_buff=probability;

for ii=1:NF
    [flow,ar,list_ec]=FindEcForFlow(probability,access_routers,graph,...
        edge_clouds);
    probability(flow,ar)=0;
    
    cache_node(flow) = list_ec(1);
    ar_list(flow) = ar;
end

total_cost=CostCalculator(cache_node,ar_list,Wsize,probability_buff,...
    Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish,edge_clouds);

end

