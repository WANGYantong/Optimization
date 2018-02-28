function cost = CostCalculator(pre_allocate,ar_list,Wsize,probability,...
    Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish,edge_clouds)

NF=length(pre_allocate);
cost=0;

for ii=1:NF
    Rspace(pre_allocate(ii))=Rspace(pre_allocate(ii))-Wsize(ii);
    Rtotal=Rtotal - Wsize(ii);
    utilization(pre_allocate(ii))=(Fullspace-Rspace(pre_allocate(ii)))/Fullspace;
end

for ii=1:NF
    cache_cost=alpha/(1-utilization(pre_allocate(ii)));
    
    [~,path_cost]=shortestpath(graph,ar_list(ii),edge_clouds(pre_allocate(ii)));
    cache_hit_cost=probability(ii,ar_list(ii))*path_cost;
    
    cache_miss_cost=(1-probability(ii,ar_list(ii)))*punish;
    
    cost=cost+cache_cost+cache_hit_cost+cache_miss_cost;
end

end
